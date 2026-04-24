//
//  TokenModels.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

/// Auth Token
public struct AuthToken: Codable, Sendable, Equatable {
    public let accessToken: String
    public let refreshToken: String
    public let tokenType: String
    public let expiresIn: TimeInterval
    public let scope: String?
    public let issuedAt: Date
    
    /// Computed Properties
    public var expirationDate: Date {
        issuedAt.addingTimeInterval(expiresIn)
    }
    
    public var isExpired: Bool {
        Date() >= expirationDate
    }
    
    public var isNearExpiry: Bool {
        let threshold: TimeInterval = 60
        return Date() >= expirationDate.addingTimeInterval(-threshold)
    }
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case scope
        case issuedAt = "issued_at"
    }
    
    // MARK: - INITIALIZER -
    public init(
        accessToken: String,
        refreshToken: String,
        tokenType: String = "Bearer",
        expiresIn: TimeInterval,
        scope: String? = nil,
        issuedAt: Date = Date()
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.scope = scope
        self.issuedAt = issuedAt
    }
}

/// Token Refresh Request
public struct TokenRefreshRequest: Encodable, Sendable {
    public let refreshToken: String
    public let grantType: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
        case grantType = "grant_type"
    }
    
    // MARK: - INITIALIZER -
    public init(refreshToken: String) {
        self.refreshToken = refreshToken
        self.grantType = "refresh_token"
    }
}

/// Enum for Token validation result
public enum TokenValidationResult: Sendable {
    case valid(AuthToken)
    case expired(AuthToken)
    case missing
    case invalid(String)
}
