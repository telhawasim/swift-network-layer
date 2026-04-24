//
//  Logger.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation
import os.log

/// Enum for log level
public enum LogLevel: Int, Sendable {
    case verbose = 0
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4
    case none = 5
    
    /// Computed Properties
    var prefix: String {
        switch self {
        case .verbose: return "💬 VERBOSE"
        case .debug:   return "🔍 DEBUG"
        case .info:    return "ℹ️ INFO"
        case .warning: return "⚠️ WARNING"
        case .error:   return "❌ ERROR"
        case .none:    return ""
        }
    }
    
    var osLogType: OSLogType {
        switch self {
        case .verbose: return .debug
        case .debug: return   .debug
        case .info: return    .info
        case .warning: return .default
        case .error: return   .error
        case .none: return    .default
        }
    }
}
