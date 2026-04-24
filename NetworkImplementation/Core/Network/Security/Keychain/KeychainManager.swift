//
//  KeychainManager.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation
import Security

public actor KeychainManager {
    
    // MARK: - PROPERTIES -
    
    /// Singleton
    public static let shared = KeychainManager()
    
    /// Normal
    private let serviceName: String
    private let accessGroup: String?
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    // MARK: - INITIALIZER -
    public init(
        serviceName: String = Bundle.main.bundleIdentifier ?? "com.app.network.keychain",
        accessGroup: String? = nil
    ) {
        self.serviceName = serviceName
        self.accessGroup = accessGroup
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
    }
}

// MARK: - KEYCHAIN MANAGER PROTOCOL FUNCTIONS -
extension KeychainManager: KeychainManagerProtocol {
    
    public func save<T: Codable & Sendable>(_ value: T, for key: String) async throws {
        let data: Data
        
        do {
            data = try encoder.encode(value)
        } catch {
            throw KeychainError.encodingFailed
        }
        
        var query = baseQuery(for: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        
        /// Try to delete existing item first
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    public func retrieve<T: Codable & Sendable>(for key: String) async throws -> T {
        var query = baseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                throw KeychainError.itemNotFound
            }
            throw KeychainError.unexpectedStatus(status)
        }
        
        guard let data = result as? Data else {
            throw KeychainError.invalidData
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw KeychainError.decodingFailed
        }
    }
    
    public func delete(for key: String) async throws {
        let query = baseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
    
    public func exists(for key: String) async -> Bool {
        var query = baseQuery(for: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public func clear() async throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrServer as String: serviceName
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

// MARK: - HELPER FUNCTIONS -
extension KeychainManager {
    
    /// In order to set base query
    /// - Parameter key: `String` unique key
    /// - Returns: `[String: Any]` query dictionary
    private func baseQuery(for key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: key
        ]
        
        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }
        
        return query
    }
}
