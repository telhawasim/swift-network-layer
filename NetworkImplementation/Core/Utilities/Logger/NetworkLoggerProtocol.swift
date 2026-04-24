//
//  NetworkLoggerProtocol.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

/// Network Logger Protocol
public protocol NetworkLoggerProtocol: Sendable {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

public extension NetworkLoggerProtocol {
    func log(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        log(message, level: level, file: file, function: function, line: line)
    }
}
