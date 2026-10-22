//
//  AppLogger.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation
import OSLog

protocol AppLoggerProtocol: Sendable {
    func debug(_ message: String)
    func info(_ message: String)
    func error(_ message: String)
}

struct AppLogger: AppLoggerProtocol {

    // MARK: - PROPERTIES -

    /// Normal
    private let logger: Logger
    private let enabled: Bool

    // MARK: - INITIALIZER -
    init(subsystem: String, category: String, enabled: Bool) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.enabled = enabled
    }

    func debug(_ message: String) {
        guard enabled else { return }
        logger.debug("\(message, privacy: .public)")
    }

    func info(_ message: String) {
        guard enabled else { return }
        logger.info("\(message, privacy: .public)")
    }

    func error(_ message: String) {
        guard enabled else { return }
        logger.error("\(message, privacy: .public)")
    }
}
