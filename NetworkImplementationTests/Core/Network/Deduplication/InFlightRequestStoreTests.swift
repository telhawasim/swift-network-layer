import Foundation
import Testing
@testable import NetworkImplementation

@Suite("In-flight request store")
struct InFlightRequestStoreTests {
    @Test("Concurrent callers share one operation")
    func concurrentCallersShareOneOperation() async throws {
        let store = InFlightRequestStore()
        let counter = ExecutionCounter()
        let fingerprint = RequestFingerprint(rawValue: "products")
        let expectedResponse = makeResponse()

        async let first = store.response(for: fingerprint) {
            await counter.increment()
            try await Task.sleep(for: .milliseconds(100))
            return expectedResponse
        }

        async let second = store.response(for: fingerprint) {
            await counter.increment()
            try await Task.sleep(for: .milliseconds(100))
            return expectedResponse
        }

        let responses = try await (first, second)
        let executionCount = await counter.currentValue()

        #expect(responses.0.statusCode == 200)
        #expect(responses.1.statusCode == 200)
        #expect(executionCount == 1)
    }

    @Test("Cancelling one caller preserves the remaining caller")
    func individualCancellationDoesNotCancelSharedOperation() async throws {
        let store = InFlightRequestStore()
        let counter = ExecutionCounter()
        let fingerprint = RequestFingerprint(rawValue: "profile")
        let expectedResponse = makeResponse()

        let first = Task {
            try await store.response(for: fingerprint) {
                await counter.increment()
                try await Task.sleep(for: .milliseconds(200))
                return expectedResponse
            }
        }

        try await Task.sleep(for: .milliseconds(20))

        let second = Task {
            try await store.response(for: fingerprint) {
                await counter.increment()
                return expectedResponse
            }
        }

        try await Task.sleep(for: .milliseconds(20))
        first.cancel()

        do {
            _ = try await first.value
            Issue.record("The cancelled caller unexpectedly received a response.")
        } catch is CancellationError {
            // Expected. The second caller remains subscribed.
        } catch {
            Issue.record("Expected CancellationError but received: \(error)")
        }

        let response = try await second.value
        let executionCount = await counter.currentValue()

        #expect(response.statusCode == 200)
        #expect(executionCount == 1)
    }

    @Test("Completed requests are removed rather than cached")
    func completedOperationIsRemoved() async throws {
        let store = InFlightRequestStore()
        let counter = ExecutionCounter()
        let fingerprint = RequestFingerprint(rawValue: "users")
        let expectedResponse = makeResponse()

        _ = try await store.response(for: fingerprint) {
            await counter.increment()
            return expectedResponse
        }

        _ = try await store.response(for: fingerprint) {
            await counter.increment()
            return expectedResponse
        }

        let executionCount = await counter.currentValue()
        #expect(executionCount == 2)
    }

    private func makeResponse() -> RawHTTPResponse {
        RawHTTPResponse(
            data: Data("{}".utf8),
            statusCode: 200,
            headers: ["Content-Type": "application/json"]
        )
    }
}

private actor ExecutionCounter {
    private var value = 0

    func increment() {
        value += 1
    }

    func currentValue() -> Int {
        value
    }
}
