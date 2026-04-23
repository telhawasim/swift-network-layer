//
//  RetryInterceptor.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

final class RetryInterceptor: RetryableInterceptor {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private let maxRetries: Int
    private let retryDelay: TimeInterval
    
    // MARK: - INITIALIZER -
    init(maxRetries: Int = 3, retryDelay: TimeInterval = 1.0) {
        self.maxRetries = maxRetries
        self.retryDelay = retryDelay
    }
    
    func intercept(_ request: URLRequest, endpoint: any Endpoint) async throws -> URLRequest {
        request
    }
    
    func shouldRetry(error: NetworkError, retryCount: Int) async throws -> Bool {
        guard retryCount < maxRetries else { return false }
        
        switch error {
        case .timeout, .noInternetConnection, .hostUnreachable:
            let delay = retryDelay * pow(2.0, Double(retryCount))
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            return true
        default:
            return false
        }
    }
}
