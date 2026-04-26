//
//  RetryInterceptor.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import Foundation

/// Retry Interceptor Protocol
protocol RetryInterceptorProtocol {
    func shouldRetry(dueTo error: NetworkError, attempt: Int) async -> Bool
}

final class RetryInterceptor {
    
    // MARK: - PROPERTIES -
    
    /// Maximum number of retries
    private let maxRetryCount: Int
    
    // MARK: - INITIALIZER -
    init(maxRetryCount: Int = 3) {
        self.maxRetryCount = maxRetryCount
    }
}

// MARK: - RETRY INTERCEPTOR PROTOCOL FUNCTIONS -
extension RetryInterceptor: RetryInterceptorProtocol {
    
    /// Determines whether a request should be retried based on the error and attempt count
    /// - Parameters:
    ///   - error: `NetworkError` to evaluate
    ///   - attempt: `Int` current retry attempt
    /// - Returns: `Bool` true if the request should be retried
    func shouldRetry(dueTo error: NetworkError, attempt: Int) async -> Bool {
        if attempt >= maxRetryCount {
            return false
        }
        
        switch error {
        case .timeout, .noInternetConnection, .serverError:
            /// Exponential backoff delay: 1s, 2s, 4s, etc.
            let delayInSeconds = pow(2.0, Double(attempt))
            try? await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
            return true
            
        case .httpError(let statusCode, _):
            /// Retry on HTTP 429 Too Many Requests or 503 Service Unavailable
            if statusCode == 429 || statusCode == 503 {
                let delayInSeconds = pow(2.0, Double(attempt))
                try? await Task.sleep(nanoseconds: UInt64(delayInSeconds * 1_000_000_000))
                return true
            }
            return false
            
        default:
            return false
        }
    }
}
