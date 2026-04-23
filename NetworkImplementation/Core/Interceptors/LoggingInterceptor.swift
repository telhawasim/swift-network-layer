//
//  LoggingInterceptor.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

final class LoggingInterceptor: RequestInterceptor {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private let logger: NetworkLogger
    
    // MARK: - INITIALIZER -
    init(logger: NetworkLogger = NetworkLogger()) {
        self.logger = logger
    }
    
    func intercept(_ request: URLRequest, endpoint: any Endpoint) async throws -> URLRequest {
        logger.log(.info, message: "➡️ [\(endpoint.method.rawValue)] \(request.url?.absoluteString ?? "unknown")")
        return request
    }
}
