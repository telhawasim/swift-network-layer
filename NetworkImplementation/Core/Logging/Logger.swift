//
//  Logger.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation
import os.log

/// Logger Protocol
protocol LoggerProtocol {
    func debug(_ message: String, file: String, function: String, line: Int)
    func info(_ message: String, file: String, function: String, line: Int)
    func warning(_ message: String, file: String, function: String, line: Int)
    func error(_ message: String, file: String, function: String, line: Int)
}

/// Default implementation
extension LoggerProtocol {
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        debug(message, file: file, function: function, line: line)
    }

    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        info(message, file: file, function: function, line: line)
    }

    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        warning(message, file: file, function: function, line: line)
    }

    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        error(message, file: file, function: function, line: line)
    }
}

final class Logger {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let osLog: OSLog
    private let isEnabled: Bool
    
    /// Enum for Log Level
    enum LogLevel: String {
        case debug = "🔍 DEBUG"
        case info = "ℹ️ INFO"
        case warning = "⚠️ WARNING"
        case error = "❌ ERROR"
    }
    
    // MARK: - INITIALIZER -
    init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.app", category: String = "Default", isEnabled: Bool = true) {
        self.osLog = OSLog(subsystem: subsystem, category: category)
        self.isEnabled = isEnabled
    }
}

// MARK: - LOGGER PROTOCOL FUNCTIONS -
extension Logger: LoggerProtocol {
    
    /// In order to log as debug
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .debug, file: file, function: function, line: line)
    }
    
    /// In order to log as info
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .info, file: file, function: function, line: line)
    }
    
    /// In order to log as warning
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// In order to log as error
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .error, file: file, function: function, line: line)
    }
}

// MARK: - HELPER FUNCTIONS -
extension Logger {
    
    /// In order to log the message
    /// - Parameters:
    ///   - message: `String` to be displayed
    ///   - level: `LogLevel` message level
    ///   - file: `String` file directory
    ///   - function: `String` function directory
    ///   - line: `String` line directory
    private func log(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard isEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "\(level.rawValue) [\(fileName):\(line)] \(function) - \(message)"
        
#if DEBUG
        print(logMessage)
#endif
        
        /// Also log to os log
        let osLogType: OSLogType
        
        switch level {
        case .debug:
            osLogType = .debug
        case .info:
            osLogType = .info
        case .warning:
            osLogType = .default
        case .error:
            osLogType = .error
        }
        
        os_log("%{public}@", log: osLog, type: osLogType, logMessage)
    }
}
