//
//  TransferSession.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

final class TransferSession: @unchecked Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let foreground: URLSession
    let background: URLSession

    // MARK: - INITIALIZER -
    init(delegate: TransferSessionDelegate, timeout: TimeInterval, backgroundIdentifier: String) {
        let foregroundConfiguration = URLSessionConfiguration.default

        foregroundConfiguration.timeoutIntervalForRequest = timeout
        foregroundConfiguration.timeoutIntervalForResource = timeout * 10
        foregroundConfiguration.waitsForConnectivity = true
        foregroundConfiguration.requestCachePolicy = .reloadIgnoringLocalCacheData

        foreground = URLSession(
            configuration: foregroundConfiguration,
            delegate: delegate,
            delegateQueue: nil
        )

        let backgroundConfiguration = URLSessionConfiguration.background(
            withIdentifier: backgroundIdentifier
        )

        backgroundConfiguration.sessionSendsLaunchEvents = true
        backgroundConfiguration.isDiscretionary = false
        backgroundConfiguration.waitsForConnectivity = true
        backgroundConfiguration.timeoutIntervalForResource = 24 * 60 * 60

        background = URLSession(
            configuration: backgroundConfiguration,
            delegate: delegate,
            delegateQueue: nil
        )
    }

    func session(for execution: TransferExecution) -> URLSession {
        switch execution {
        case .foreground:
            return foreground

        case .background:
            return background
        }
    }
}
