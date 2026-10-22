//
//  TransferOperation.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

struct TransferOperation<Value: Sendable>: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let identifier: String
    let taskIdentifier: Int
    let progress: AsyncStream<TransferProgress>
    /// Private
    private let resultTask: Task<Value, Error>
    private let cancellation: @Sendable () -> Void

    // MARK: - INITIALIZER -
    init(
        identifier: String,
        taskIdentifier: Int,
        progress: AsyncStream<TransferProgress>,
        resultTask: Task<Value, Error>,
        cancellation: @Sendable @escaping () -> Void
    ) {
        self.identifier = identifier
        self.taskIdentifier = taskIdentifier
        self.progress = progress
        self.resultTask = resultTask
        self.cancellation = cancellation
    }

    func value() async throws -> Value {
        try await resultTask.value
    }

    func cancel() {
        cancellation()
    }

    func map<MappedValue: Sendable>(
        _ transform: @Sendable @escaping (Value) throws -> MappedValue
    ) -> TransferOperation<MappedValue> {
        let mappedTask = Task<MappedValue, Error> {
            try transform(try await resultTask.value)
        }

        return TransferOperation<MappedValue>(
            identifier: identifier,
            taskIdentifier: taskIdentifier,
            progress: progress,
            resultTask: mappedTask,
            cancellation: cancellation
        )
    }
}

struct DownloadOperation: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let transfer: TransferOperation<DownloadFile>
    /// Private
    private let pauseAction: @Sendable () async throws -> DownloadResumeToken?

    // MARK: - INITIALIZER -
    init(
        transfer: TransferOperation<DownloadFile>,
        pauseAction: @Sendable @escaping () async throws -> DownloadResumeToken?
    ) {
        self.transfer = transfer
        self.pauseAction = pauseAction
    }

    func pause() async throws -> DownloadResumeToken? {
        try await pauseAction()
    }
}
