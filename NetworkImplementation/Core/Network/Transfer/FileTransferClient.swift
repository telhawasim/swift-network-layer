//
//  FileTransferClient.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

actor FileTransferClient: FileTransferClientProtocol {

    // MARK: - PROPERTIES -

    /// Nomal
    private let requestBuilder: any RequestBuilderProtocol
    private let sessions: TransferSession
    private let delegate: TransferSessionDelegate
    private let multipartEncoder: MultipartFormEncoder
    private let resumeStore: any DownloadResumeStoring
    private let validator: DownloadFileValidator

    // MARK: - INITIALIZER -
    init(
        requestBuilder: any RequestBuilderProtocol,
        sessions: TransferSession,
        delegate: TransferSessionDelegate,
        multipartEncoder: MultipartFormEncoder,
        resumeStore: any DownloadResumeStoring,
        validator: DownloadFileValidator
    ) {
        self.requestBuilder = requestBuilder
        self.sessions = sessions
        self.delegate = delegate
        self.multipartEncoder = multipartEncoder
        self.resumeStore = resumeStore
        self.validator = validator
    }

    func upload<Response>(
        _ upload: MultipartUploadRequest<Response>
    ) async throws -> TransferOperation<APIResponse<Response>> where Response: Decodable & Sendable {
        let encodedFile = try await multipartEncoder.encode(upload.form)
        let urlRequest: URLRequest

        do {
            var request = try await requestBuilder.build(upload.request)
            request.setValue(encodedFile.contentType, forHTTPHeaderField: "Content-Type")
            request.setValue(String(encodedFile.contentLength), forHTTPHeaderField: "Content-Length")
            urlRequest = request
        } catch {
            await multipartEncoder.remove(encodedFile)
            throw error
        }

        let task = sessions
            .session(for: upload.execution)
            .uploadTask(with: urlRequest, fromFile: encodedFile.url)
        task.taskDescription = "multipart|\(encodedFile.cleanupIdentifier)|\(upload.identifier)"

        let registration = delegate.register(task: task)

        let resultTask = Task<APIResponse<Response>, Error> {
            let result = try await registration.result.value

            guard case .upload(let data, let response) = result else {
                throw TransferError.invalidHTTPResponse
            }

            guard (200...299).contains(response.statusCode) else {
                throw TransferError.http(statusCode: response.statusCode)
            }

            if data.isEmpty, let empty = EmptyResponse() as? Response {
                return APIResponse(
                    value: empty,
                    statusCode: response.statusCode,
                    headers: response.headers
                )
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase

                let value = try decoder.decode(Response.self, from: data)

                return APIResponse(
                    value: value,
                    statusCode: response.statusCode,
                    headers: response.headers
                )
            } catch {
                throw TransferError.responseDecoding(error.localizedDescription)
            }
        }

        task.resume()

        return TransferOperation(
            identifier: upload.identifier,
            taskIdentifier: task.taskIdentifier,
            progress: registration.progress,
            resultTask: resultTask,
            cancellation: {
                task.cancel()
            }
        )
    }

    func download(_ request: DownloadRequest) async throws -> DownloadOperation {
        let urlRequest = try await requestBuilder.build(request.request)
        let task = sessions
            .session(for: request.execution)
            .downloadTask(with: urlRequest)

        return makeDownloadOperation(task: task, request: request)
    }

    func resumeDownload(
        _ request: DownloadRequest,
        token: DownloadResumeToken
    ) async throws -> DownloadOperation {
        guard token.identifier == request.resumeIdentifier else {
            throw TransferError.missingResumeData
        }

        guard let resumeData = try await resumeStore.load(identifier: token.identifier) else {
            throw TransferError.missingResumeData
        }

        let task = sessions
            .session(for: request.execution)
            .downloadTask(withResumeData: resumeData)

        return makeDownloadOperation(task: task, request: request)
    }
}

// MARK: - HELPER FUNCTIONS -
extension FileTransferClient {

    private func makeDownloadOperation(
        task: URLSessionDownloadTask,
        request: DownloadRequest
    ) -> DownloadOperation {
        let registration = delegate.register(task: task)
        let resumeStore = self.resumeStore
        let validator = self.validator

        let resultTask = Task<DownloadFile, Error> {
            var stagedFileToRemove: URL?
            defer {
                if let stagedFileToRemove {
                    try? FileManager.default.removeItem(at: stagedFileToRemove)
                }
            }

            do {
                let result = try await registration.result.value

                guard case .download(let stagedFile, let response) = result else {
                    throw TransferError.invalidHTTPResponse
                }
                stagedFileToRemove = stagedFile

                guard (200...299).contains(response.statusCode) else {
                    try? FileManager.default.removeItem(at: stagedFile)

                    throw TransferError.http(statusCode: response.statusCode)
                }

                let downloadedFile = try await validator.validateAndMove(
                    stagedFile: stagedFile,
                    response: response,
                    destination: request.destination,
                    policy: request.validation
                )

                try? await resumeStore.remove(identifier: request.resumeIdentifier)
                stagedFileToRemove = nil

                return downloadedFile
            } catch let error as TransferSessionError {
                switch error {
                case .transport(let description, let resumeData):
                    guard let resumeData else {
                        throw TransferError.transport(description)
                    }

                    try await resumeStore.save(resumeData, identifier: request.resumeIdentifier)

                    throw TransferError.interrupted(
                        resumeToken: DownloadResumeToken(identifier: request.resumeIdentifier)
                    )

                case .missingResponse:
                    throw TransferError.invalidHTTPResponse

                case .missingDownload:
                    throw TransferError.missingDownloadedFile
                }
            }
        }

        task.resume()

        let transfer = TransferOperation(
            identifier: request.resumeIdentifier,
            taskIdentifier: task.taskIdentifier,
            progress: registration.progress,
            resultTask: resultTask,
            cancellation: {
                task.cancel()
            }
        )

        return DownloadOperation(
            transfer: transfer,
            pauseAction: {
                let resumeData: Data? = await withCheckedContinuation { continuation in
                    task.cancel { data in
                        continuation.resume(returning: data)
                    }
                }

                guard let resumeData else {
                    return nil
                }

                try await resumeStore.save(resumeData, identifier: request.resumeIdentifier)

                return DownloadResumeToken(identifier: request.resumeIdentifier)
            }
        )
    }
}
