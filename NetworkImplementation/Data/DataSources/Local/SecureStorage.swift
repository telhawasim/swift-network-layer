//
//  SecureStorage.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Secure Storage Protocol
protocol SecureStorage {
    func saveToken(_ token: String, type: TokenType) async throws
    func getToken(type: TokenType) async throws -> String?
    func deleteToken(type: TokenType) async throws
    func clearAll() async throws
}

/// Enum for Token Type
enum TokenType: String {
    case access = "access_token"
    case refresh = "refresh_token"
}

final class KeychainSecureStorage: SecureStorage {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let keychainManager: KeychainManagerProtocol
    
    // MARK: - INITIALIZER -
    init(keychainManager: KeychainManagerProtocol = KeychainManager.shared) {
        self.keychainManager = keychainManager
    }
    
    func saveToken(_ token: String, type: TokenType) async throws {
        try keychainManager.saveString(token, forKey: type.rawValue)
    }
    
    func getToken(type: TokenType) async throws -> String? {
        return try keychainManager.retrieveString(forKey: type.rawValue)
    }
    
    func deleteToken(type: TokenType) async throws {
        try keychainManager.delete(forKey: type.rawValue)
    }
    
    func clearAll() async throws {
        try await deleteToken(type: .access)
        try await deleteToken(type: .refresh)
    }
}
