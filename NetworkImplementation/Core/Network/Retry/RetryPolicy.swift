//
//  RetryPolicy.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

protocol RetryPolicyProtocol: Sendable {
    func delay<Response>(
        for request: APIRequest<Response>,
        error: NetworkError,
        attempt: Int
    ) -> Duration? where Response: Decodable & Sendable
}

struct ExponentialBackoffRetryPolicy: RetryPolicyProtocol {

    // MARK: - PROPERTIES -

    /// Normal
    private let maximumRetryCount: Int
    private let baseDelay: TimeInterval
    private let maximumDelay: TimeInterval
    private let jitter: @Sendable () -> Double

    // MARK: - INITIALIZER -
    init(
        maximumRetryCount: Int,
        baseDelay: TimeInterval = 1,
        maximumDelay: TimeInterval = 30,
        jitter: @Sendable @escaping () -> Double = { Double.random(in: 0...1) }
    ) {
        self.maximumRetryCount = maximumRetryCount
        self.baseDelay = baseDelay
        self.maximumDelay = maximumDelay
        self.jitter = jitter
    }

    func delay<Response>(
        for request: APIRequest<Response>,
        error: NetworkError,
        attempt: Int
    ) -> Duration? where Response : Decodable & Sendable {
        guard attempt < maximumRetryCount else {
            return nil
        }

        guard request.retryBehavior.allowsRetry(for: request.method) else {
            return nil
        }

        if let retryAfter = error.retryAfter {
            return .seconds(min(retryAfter, maximumDelay))
        }

        guard isRecoverable(error) else {
            return nil
        }

        let exponentialDelay = baseDelay * pow(2, Double(attempt))
        let jitterMultiplier = 0.8 + (jitter() * 0.4)
        let delay = min(exponentialDelay * jitterMultiplier, maximumDelay)

        return .seconds(delay)
    }
}

// MARK: - HELPER FUNCTIONS -
extension ExponentialBackoffRetryPolicy {

    private func isRecoverable(_ error: NetworkError) -> Bool {
        switch error {
        case .timedOut:
            return true

        case .transport(let code, _):
            return [
                URLError.networkConnectionLost.rawValue,
                URLError.cannotConnectToHost.rawValue,
                URLError.cannotFindHost.rawValue,
                URLError.dnsLookupFailed.rawValue
            ].contains(code)

        case .http(let code, _, _):
            return [429, 500, 502, 503, 504].contains(code)

        default:
            return false
        }
    }
}
