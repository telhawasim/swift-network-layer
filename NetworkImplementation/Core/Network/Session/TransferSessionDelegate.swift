//
//  TransferSessionDelegate.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

struct TransferHTTPResponse: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let statusCode: Int
    let headers: [String: String]
    let mimeType: String?
    let expectedContentLength: Int64

    // MARK: - INITIALIZER -
    init(_ response: HTTPURLResponse) {
        statusCode = response.statusCode
        mimeType = response.mimeType
        expectedContentLength = response.expectedContentLength

        headers = response.allHeaderFields.reduce(into: [:]) { result, entry in
            result[String(describing: entry.key)] = String(describing: entry.value)
        }
    }
}

enum TransferSessionResult: Sendable {
    case upload(data: Data, response: TransferHTTPResponse)
    case download(stagedFile: URL, response: TransferHTTPResponse)
}

enum TransferSessionError: Error {
    case transport(description: String, resumeData: Data?)
    case missingResponse
    case missingDownload
}

final class TransferSessionDelegate: NSObject, @unchecked Sendable {

    struct Registration: Sendable {
        let progress: AsyncStream<TransferProgress>
        let result: Task<TransferSessionResult, Error>
    }

    private final class State {
        var responseData = Data()
        var stagedFile: URL?
        var progressContinuation: AsyncStream<TransferProgress>.Continuation?
        var resultContinuation: CheckedContinuation<TransferSessionResult, Error>?
        var completedResult: Result<TransferSessionResult, Error>?
        var isFinished = false
    }

    private let lock = NSLock()
    private var states: [Int: State] = [:]
    private let trustEvaluator: ServerTrustEvaluator
    private let backgroundEventsFinished: @Sendable () -> Void

    // MARK: - INITIALIZER -
    init(
        trustEvaluator: ServerTrustEvaluator,
        backgroundEventsFinished: @Sendable @escaping () -> Void
    ) {
        self.trustEvaluator = trustEvaluator
        self.backgroundEventsFinished = backgroundEventsFinished
    }
}

// MARK: - HELPER FUNCTIONS -
extension TransferSessionDelegate {

    func register(task: URLSessionTask) -> Registration {
        let state = State()
        let progress = AsyncStream<TransferProgress>(
            bufferingPolicy: .bufferingNewest(1)
        ) { continuation in
            state.progressContinuation = continuation
        }

        lock.withLock {
            states[task.taskIdentifier] = state
        }

        let result = Task {
            try await self.result(for: task.taskIdentifier)
        }

        return Registration(progress: progress, result: result)
    }

    private func result(for taskIdentifier: Int) async throws -> TransferSessionResult {
        try await withCheckedThrowingContinuation { continuation in
            var completed: Result<TransferSessionResult, Error>?

            lock.withLock {
                guard let state = states[taskIdentifier] else {
                    completed = .failure(TransferSessionError.missingResponse)
                    return
                }

                if let result = state.completedResult {
                    completed = result
                    states[taskIdentifier] = nil
                } else {
                    state.resultContinuation = continuation
                }
            }

            if let completed {
                continuation.resume(with: completed)
            }
        }
    }

    private func publish(taskIdentifier: Int, completed: Int64, expected: Int64) {
        let continuation = lock.withLock {
            states[taskIdentifier]?.progressContinuation
        }

        continuation?
            .yield(
                TransferProgress(
                    completedBytes: completed,
                    expectedBytes: expected > 0 ? expected : nil
                )
            )
    }

    private func finish(taskIdentifier: Int, result: Result<TransferSessionResult, Error>) {
        var resultContinuation: CheckedContinuation<TransferSessionResult, Error>?
        var progressContinuation: AsyncStream<TransferProgress>.Continuation?

        lock.withLock {
            guard let state = states[taskIdentifier] else {
                return
            }

            guard !state.isFinished else { return }
            state.isFinished = true

            progressContinuation = state.progressContinuation
            resultContinuation = state.resultContinuation

            if resultContinuation == nil {
                state.completedResult = result
            } else {
                states[taskIdentifier] = nil
            }
        }

        progressContinuation?.finish()
        resultContinuation?.resume(with: result)
    }
}

// MARK: - DELEGATE METHODS FOR URLSESSION DATA DELEGATE AND URLSESSION DOWNLOAD DELEGATE
extension TransferSessionDelegate: URLSessionDataDelegate, URLSessionDownloadDelegate {

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        publish(
            taskIdentifier: task.taskIdentifier,
            completed: totalBytesSent,
            expected: totalBytesExpectedToSend
        )
    }

    func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data,
    ) {
        lock.withLock {
            states[dataTask.taskIdentifier]?.responseData.append(data)
        }
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        publish(
            taskIdentifier: downloadTask.taskIdentifier,
            completed: totalBytesWritten,
            expected: totalBytesExpectedToWrite
        )
    }

    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let stagedURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("download")

        do {
            try FileManager.default.moveItem(at: location, to: stagedURL)

            lock.withLock {
                states[downloadTask.taskIdentifier]?.stagedFile = stagedURL
            }
        } catch {
            finish(taskIdentifier: downloadTask.taskIdentifier, result: .failure(error))
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
        defer { removeMultipartBodyIfNeeded(for: task) }

        if let error {
            let nsError = error as NSError
            let resumeData = nsError.userInfo[NSURLSessionDownloadTaskResumeData] as? Data
            let result: Result<TransferSessionResult, Error>

            if nsError.code == NSURLErrorCancelled,
               resumeData == nil {
                result = .failure(TransferError.cancelled)
            } else {
                result = .failure(
                    TransferSessionError
                        .transport(
                            description: error.localizedDescription,
                            resumeData: resumeData
                        )
                )
            }

            finish(taskIdentifier: task.taskIdentifier, result: result)

            return
        }

        guard let response = task.response as? HTTPURLResponse else {
            finish(
                taskIdentifier: task.taskIdentifier,
                result: .failure(TransferSessionError.missingResponse)
            )
            return
        }

        let state = lock.withLock {
            states[task.taskIdentifier]
        }

        guard let state else {
            return
        }

        let result: TransferSessionResult

        if task is URLSessionDownloadTask {
            guard let stagedFile = state.stagedFile else {
                finish(
                    taskIdentifier: task.taskIdentifier,
                    result: .failure(TransferSessionError.missingDownload)
                )
                return
            }

            result = .download(stagedFile: stagedFile, response: TransferHTTPResponse(response))
        } else {
            result = .upload(data: state.responseData, response: TransferHTTPResponse(response))
        }

        finish(taskIdentifier: task.taskIdentifier, result: .success(result))
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        backgroundEventsFinished()
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        let evaluation = trustEvaluator.evaluate(challenge)

        completionHandler(evaluation.disposition, evaluation.credential)
    }
}

// MARK: - TEMPORARY FILE CLEANUP
extension TransferSessionDelegate {

    private func removeMultipartBodyIfNeeded(for task: URLSessionTask) {
        guard let description = task.taskDescription,
              description.hasPrefix("multipart|"),
              description.split(separator: "|").count == 3,
              let filename = description.split(separator: "|").dropFirst().first.map(String.init),
              filename == URL(fileURLWithPath: filename).lastPathComponent else {
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(MultipartFormEncoder.directoryName, isDirectory: true)
            .appendingPathComponent(filename)

        try? FileManager.default.removeItem(at: url)
    }
}
