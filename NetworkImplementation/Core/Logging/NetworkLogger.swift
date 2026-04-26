//
//  NetworkLogger.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Network Layer Protocol
protocol NetworkLoggerProtocol {
    func logRequest(_ request: URLRequest)
    func logResponse(_ request: URLResponse?, data: Data?)
    func logError(_ error: Error)
}

final class NetworkLogger {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let logger: LoggerProtocol
    private let isVerbose: Bool
    
    // MARK: - INITIALIZER -
    init(logger: LoggerProtocol = Logger(category: "Network"), isVerbose: Bool = true) {
        self.logger = logger
        self.isVerbose = isVerbose
    }
}

// MARK: - NETWORK LOGGER PROTOCOL FUNCTIONS -
extension NetworkLogger: NetworkLoggerProtocol {
    
    /// In order to log request
    /// - Parameter request: `URLRequest` to be logged
    func logRequest(_ request: URLRequest) {
        guard isVerbose else { return }
        
        var logMessage = "\n========== REQUEST ==========\n"
        logMessage += "URL: \(request.url?.absoluteString ?? "nil")\n"
        logMessage += "Method: \(request.httpMethod ?? "nil")\n"
        
        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            logMessage += "Headers:\n"
            headers.forEach { key, value in
                // Mask authorization header for security
                let maskedValue = key.lowercased() == "authorization" ? "Bearer ***" : value
                logMessage += "  \(key): \(maskedValue)\n"
            }
        }
        
        if let body = request.httpBody,
           let bodyString = String(data: body, encoding: .utf8) {
            logMessage += "Body: \(bodyString)\n"
        }
        
        logMessage += "============================\n"
        logger.debug(logMessage)
    }
    
    /// In order to log response
    /// - Parameters:
    ///   - response: `URLResponse?` log response
    ///   - data: `Data?` log data
    func logResponse(_ response: URLResponse?, data: Data?) {
        guard isVerbose else { return }
        
        var logMessage = "\n========== RESPONSE ==========\n"
        
        if let httpResponse = response as? HTTPURLResponse {
            logMessage += "Status Code: \(httpResponse.statusCode)\n"
            logMessage += "URL: \(httpResponse.url?.absoluteString ?? "nil")\n"
            
            if !httpResponse.allHeaderFields.isEmpty {
                logMessage += "Headers:\n"
                httpResponse.allHeaderFields.forEach { key, value in
                    logMessage += "  \(key): \(value)\n"
                }
            }
        }
        
        if let data = data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                logMessage += "Body:\n\(prettyString)\n"
            } else if let bodyString = String(data: data, encoding: .utf8) {
                logMessage += "Body: \(bodyString)\n"
            }
        }
        
        logMessage += "==============================\n"
        logger.debug(logMessage)
    }
    
    /// In order to log error
    /// - Parameter error: `Error` to be logged error
    func logError(_ error: Error) {
        var logMessage = "\n========== ERROR ==========\n"
        logMessage += "Error: \(error.localizedDescription)\n"
        
        if let networkError = error as? NetworkError {
            logMessage += "Type: \(networkError)\n"
        }
        
        logMessage += "===========================\n"
        logger.error(logMessage)
    }
}
