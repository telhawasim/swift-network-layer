//
//  LoggingInterceptor.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

final class LoggingInterceptor {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let logger: NetworkLoggerProtocol
    
    // MARK: - INITIALIZER -
    init(logger: NetworkLoggerProtocol = NetworkLogger()) {
        self.logger = logger
    }
    
    /// In order to log the request
    /// - Parameter request: `URLRequest` request which needs to be logged
    func logRequest(_ request: URLRequest) {
        logger.logRequest(request)
    }
    
    /// In order to log the response
    /// - Parameters:
    ///   - response: `URLResponse?` response which needs to be logged
    ///   - data: `Data?` data against that response
    func logResponse(_ response: URLResponse?, data: Data?) {
        logger.logResponse(response, data: data)
    }
    
    /// In order to log Error
    /// - Parameter error: `Error` which needs to show
    func logError(_ error: Error) {
        logger.logError(error)
    }
}
