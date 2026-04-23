//
//  RequestInterceptor.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

protocol RequestInterceptor {
    func intercept(
        _ request: URLRequest,
        endpoint: Endpoint
    ) async throws -> URLRequest
}

protocol RetryableInterceptor: RequestInterceptor {
    func shouldRetry(
        error: NetworkError,
        retryCount: Int
    ) async throws -> Bool
}
