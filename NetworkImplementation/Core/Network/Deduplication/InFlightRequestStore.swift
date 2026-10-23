//
//  InFlightRequestStore.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

protocol InFlightRequestStoring: Sendable {
    func response(
        for fingerprint: RequestFingerprint,
        operation: @escaping @Sendable () async throws -> RawHTTPResponse
    ) async throws -> RawHTTPResponse
}

actor InFlightRequestStore: InFlightRequestStoring {

    private typealias ResponseContinuation = CheckedContinuation<RawHTTPResponse, Error>

    private struct Entry {
        let task: Task<Void, Never>
        var waiters: [UUID: ResponseContinuation]
    }

    private var entries: [RequestFingerprint: Entry] = [:]

    func response(
        for fingerprint: RequestFingerprint,
        operation: @escaping @Sendable () async throws -> RawHTTPResponse
    ) async throws -> RawHTTPResponse {
        let waiterID = UUID()

        return try await withTaskCancellationHandler {
            try Task.checkCancellation()

            return try await withCheckedThrowingContinuation { continuation in
                register(
                    continuation,
                    waiterID: waiterID,
                    fingerprint: fingerprint,
                    operation: operation
                )
            }
        } onCancel: {
            Task {
                await self.cancelWaiter(waiterID, fingerprint: fingerprint)
            }
        }
    }
}

// MARK: - HELPER FUNCTIONS -
extension InFlightRequestStore {

    private func register(
        _ continuation: ResponseContinuation,
        waiterID: UUID,
        fingerprint: RequestFingerprint,
        operation: @escaping @Sendable () async throws -> RawHTTPResponse
    ) {
        guard !Task.isCancelled else {
            continuation.resume(throwing: CancellationError())
            return
        }

        if var existingEntry = entries[fingerprint] {
            existingEntry.waiters[waiterID] = continuation
            entries[fingerprint] = existingEntry
            return
        }

        let task = Task.detached { [weak self] in
            let result: Result<RawHTTPResponse, Error>

            do {
                result = .success(try await operation())
            } catch {
                result = .failure(error)
            }

            await self?.finish(fingerprint: fingerprint, result: result)
        }

        entries[fingerprint] = Entry(task: task, waiters: [waiterID: continuation])
    }

    private func finish(
        fingerprint: RequestFingerprint,
        result: Result<RawHTTPResponse, Error>
    ) {
        guard let entry = entries.removeValue(forKey: fingerprint) else {
            return
        }

        for continuation in entry.waiters.values {
            continuation.resume(with: result)
        }
    }

    private func cancelWaiter(_ waiterID: UUID, fingerprint: RequestFingerprint) {
        guard var entry = entries[fingerprint],
              let continuation = entry.waiters.removeValue(forKey: waiterID) else {
            return
        }

        continuation.resume(throwing: CancellationError())

        if entry.waiters.isEmpty {
            entries.removeValue(forKey: fingerprint)
            entry.task.cancel()
        } else {
            entries[fingerprint] = entry
        }
    }
}
