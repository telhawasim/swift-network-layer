//
//  PinningConfigurationError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 21/10/2026.
//

import Foundation

enum PinningConfigurationError: Error, Sendable {
    case enabledWithoutHosts
    case enabledWithoutPins(host: String)
    case invalidPin(host: String)
}

extension PinningConfigurationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .enabledWithoutHosts:
            return "Certificate pinning is enabled without a pinned host."
        case .enabledWithoutPins(let host):
            return "Certificate pinning is enabled without pins for \(host)."
        case .invalidPin(let host):
            return "A certificate pin for \(host) is not a base64 SHA-256 digest."
        }
    }
}
