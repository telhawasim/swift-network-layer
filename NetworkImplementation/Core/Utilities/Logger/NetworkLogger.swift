//
//  NetworkLogger.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation
import os.log

public actor NetworkLogger {
    
    // MARK: - PROPERTIES -
    
    /// Singleton
    public static let shared = NetworkLogger()
    
    /// Normal
    private let subsystem: String
    private let category: String
    private var minimumLevel: LogLevel
    private let osLog: OSLog
    private var logHistory: [LogEntry] = []
    private let maxHistoryCount = 1000
    
    /// Enum for Log Entry
    public struct LogEntry: Sendable {
        let timestamp: Date
        let level: LogLevel
        let message: String
        let file: String
        let function: String
        let line: Int
    }
    
    // MARK: - INITIALZIER -
    private init(
        subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.network.implementation",
        category: String = "Network",
        minimumLevel: LogLevel = .debug
    ) {
        self.subsystem = subsystem
        self.category = category
        self.minimumLevel = minimumLevel
        self.osLog = OSLog(subsystem: subsystem, category: category)
    }
    
    /// In order to set the minimum level
    /// - Parameter level: `LogLevel` leve which needs to be set as minimum level
    public func setMinimumLevel(_ level: LogLevel) {
        self.minimumLevel = level
    }
    
    /// In order to get the log history
    /// - Parameter level: `LogLevel?` level which needs to be fetched
    /// - Returns: `[LogEntry]` log entries array
    public func getHistory(for level: LogLevel? = nil) -> [LogEntry] {
        guard let level else { return logHistory }
        return logHistory.filter { $0.level == level }
    }
    
    /// In order to remove the log history
    public func clearHistory() {
        logHistory.removeAll()
    }
}

// MARK: - NETWORK LOGGER PROTOCOL FUNCTIONS -
extension NetworkLogger: NetworkLoggerProtocol {
    
    public nonisolated func log(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        Task {
            await self.performLog(message, level: level, file: file, function: function, line: line)
        }
    }
}

// MARK: - HELPER FUNCTIONS -
extension NetworkLogger {
    
    /// In order to perform the log
    /// - Parameters:
    ///   - message: `String` message to be shown
    ///   - level: `LogLevel` level to be shown
    ///   - file: `String` file to be shown
    ///   - function: `String` function to be shown
    ///   - line: `Int` line to be shown
    private func performLog(_ message: String, level: LogLevel, file: String, function: String, line: Int) {
        guard level.rawValue >= minimumLevel.rawValue else { return }
        
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let formattedMessage = "[\(level.prefix)] [\(fileName):\(line)] \(function) → \(message)"
        
        os_log("%{public}@", log: osLog, type: level.osLogType, formattedMessage)
        
        #if DEBUG
        print(formattedMessage)
        #endif
        
        let entry = LogEntry(
            timestamp: Date(),
            level: level,
            message: message,
            file: file,
            function: function,
            line: line
        )
        
        logHistory.append(entry)
        if logHistory.count > maxHistoryCount {
            logHistory.removeFirst()
        }
    }
}

/// Global network logger function
/// - Parameters:
///   - message: `String` message to be shown
///   - level: `LogLevel` level to be shown
///   - file: `String` file to be shown
///   - function: `String` function to be shown
///   - line: `Int` line to be shown
public func networkLog(
    _ message: String,
    level: LogLevel = .debug,
    file: String = #file,
    function: String = #function,
    line: Int = #line
) {
    NetworkLogger.shared.log(message, level: level, file: file, function: function, line: line)
}
