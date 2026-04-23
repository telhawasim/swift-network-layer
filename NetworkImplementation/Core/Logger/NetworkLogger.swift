//
//  NetworkLogger.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation
import os.log

final class NetworkLogger {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private let logLevel: NetworkLogLevel
    private let logger: Logger
    
    // MARK: - INITIALIZER -
    init(
        logLevel: NetworkLogLevel = .verbose,
        subsystem: String = Bundle.main.bundleIdentifier ?? "NetworkLayer"
    ) {
        self.logLevel = logLevel
        self.logger = Logger(subsystem: subsystem, category: "Network")
    }
    
    /// In order to log for the network calls
    /// - Parameters:
    ///   - level: `NetworkLogLevel` will determine in what state the call is in
    ///   - message: `String` message to be shown
    func log(_ level: NetworkLogLevel, message: String) {
        guard level <= logLevel else { return }
        
        let prefix: String
        switch level {
        case .none:    return
        case .error:   prefix = "❌ [ERROR]"
        case .warning: prefix = "⚠️ [WARNING]"
        case .info:    prefix = "ℹ️ [INFO]"
        case .debug:   prefix = "🔍 [DEBUG]"
        case .verbose: prefix = "📋 [VERBOSE]"
        }
        
        let full = "\(prefix) \(message)"
        
#if DEBUG
        print(full)
#endif
        
        switch level {
        case .error:          logger.error("\(full)")
        case .warning:        logger.warning("\(full)")
        case .info:           logger.info("\(full)")
        case .debug, .verbose:logger.debug("\(full)")
        case .none:           break
        }
    }
    
    /// In order to log the request
    /// - Parameter request: `URLRequest` request
    func logRequest(_ request: URLRequest) {
        guard logLevel >= .debug else { return }
        var msg = """
            
            ╔══════════════════════════════════════════
            ║ 📤 REQUEST
            ╠══════════════════════════════════════════
            ║ URL     : \(request.url?.absoluteString ?? "N/A")
            ║ Method  : \(request.httpMethod ?? "N/A")
            ║ Headers : \(request.allHTTPHeaderFields ?? [:])
            """
        if let body = request.httpBody,
           let str = String(data: body, encoding: .utf8) {
            msg += "\n║ Body    : \(str)"
        }
        msg += "\n╚══════════════════════════════════════════\n"
        log(.debug, message: msg)
    }
    
    /// In order to log the response
    /// - Parameters:
    ///   - response: `HTTPURLResponse` server response
    ///   - data: `Data?` body parameters
    ///   - url: `URL?` url from request
    func logResponse(_ response: HTTPURLResponse, data: Data?, url: URL?) {
        guard logLevel >= .debug else { return }
        var msg = """
            
            ╔══════════════════════════════════════════
            ║ 📥 RESPONSE
            ╠══════════════════════════════════════════
            ║ URL     : \(url?.absoluteString ?? "N/A")
            ║ Status  : \(response.statusCode) \(response.statusDescription)
            ║ Headers : \(response.allHeaderFields)
            """
        if let data,
           let str = String(data: data, encoding: .utf8) {
            let preview = String(str.prefix(1000))
            msg += "\n║ Body    : \(preview)"
            if str.count > 1000 { msg += "... (truncated)" }
        }
        msg += "\n╚══════════════════════════════════════════\n"
        let level: NetworkLogLevel = (200...299).contains(response.statusCode) ? .debug : .error
        log(level, message: msg)
    }
}
