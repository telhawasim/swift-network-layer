//
//  TokenManager.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Token Manager Protocol
protocol TokenManagerProtocol {
    func saveAccessToken(_ token: String) async throws
    func saveRefreshToken(_ token: String) async throws
    func getAccessToken() async throws -> String?
    func getRefreshToken() async throws -> String?
    func clearTokens() async throws
}

final class TokenManager {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let keychainManager: KeychainManagerProtocol
    
    /// Normal
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let cache = TokenCache()
    
    /// Token Cache
    private actor TokenCache {
        private var accessToken: String?
        private var refreshToken: String?
        
        func setAccessToken(_ token: String?) {
            accessToken = token
        }
        
        func setRefreshToken(_ token: String?) {
            refreshToken = token
        }
        
        func getAccessToken() -> String? {
            return accessToken
        }
        
        func getRefreshToken() -> String? {
            return refreshToken
        }
        
        func clear() {
            accessToken = nil
            refreshToken = nil
        }
    }
    
    // MARK: - INITIALIZER -
    init(keychainManager: KeychainManagerProtocol = KeychainManager.shared) {
        self.keychainManager = keychainManager
    }
}

// MARK: - TOKEN MANAGER PROTOCOL FUCNTIONS -
extension TokenManager: TokenManagerProtocol {
    
    /// In order to save access token
    /// - Parameter token: `String` to be saved
    func saveAccessToken(_ token: String) async throws {
        try keychainManager.saveString(token, forKey: accessTokenKey)
        await cache.setAccessToken(token)
    }
    
    /// In order to save refresh token
    /// - Parameter token: `String` to be saved
    func saveRefreshToken(_ token: String) async throws {
        try keychainManager.saveString(token, forKey: refreshTokenKey)
        await cache.setRefreshToken(token)
    }
    
    /// In order to get access token
    /// - Returns: `String?` optional token
    func getAccessToken() async throws -> String? {
        /// Check cache first
        if let cachedToken = await cache.getAccessToken() {
            return cachedToken
        }
        
        /// Retrieve from keychain
        let token = try keychainManager.retrieveString(forKey: accessTokenKey)
        await cache.setAccessToken(token)
        return token
    }
    
    /// In order to get refresh token
    /// - Returns: `String?` optional token
    func getRefreshToken() async throws -> String? {
        /// Check cache first
        if let cachedToken = await cache.getRefreshToken() {
            return cachedToken
        }
        
        /// Retrive from keychain
        let token = try keychainManager.retrieveString(forKey: refreshTokenKey)
        await cache.setRefreshToken(token)
        return token
    }
    
    /// In order to clear tokens
    func clearTokens() async throws {
        try keychainManager.delete(forKey: accessTokenKey)
        try keychainManager.delete(forKey: refreshTokenKey)
        await cache.clear()
    }
}
