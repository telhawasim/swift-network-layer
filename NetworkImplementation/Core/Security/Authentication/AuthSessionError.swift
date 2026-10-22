//
//  AuthSessionError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Enum responsible for all Auth Session Errors
enum AuthSessionError: Error, Sendable {
    case unauthenticated
    case missingRefreshToken
    case refreshFailed
}

extension AuthSessionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unauthenticated: return "Authentication is required."
        case .missingRefreshToken: return "The session does not contain a refresh token."
        case .refreshFailed: return "The session could not be refreshed."
        }
    }
}
