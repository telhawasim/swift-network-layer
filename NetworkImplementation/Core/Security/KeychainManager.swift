//
//  KeychainManager.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Keychain Manager Protocol
protocol KeychainManagerProtocol {
    func save(_ data: Data, forKey key: String) throws
    func retrieve(forKey key: String) throws -> Data?
    func delete(forKey key: String) throws
    func saveString(_ string: String, forKey key: String) throws
    func retrieveString(forKey key: String) throws -> String?
}

final class KeychainManager {
    
    // MARK: - PROPERTIES -
    
    /// Singleton
    static let shared = KeychainManager()
    
    /// Dependencies
    private let service: String
    
    // MARK: - INITIALIZER -
    init(service: String = Bundle.main.bundleIdentifier ?? "com.app.keychain") {
        self.service = service
    }
}

// MARK: - KEYCHAIN MANAGER PROTOCOL FUNCTIONS -
extension KeychainManager: KeychainManagerProtocol {
    
    /// In order to save the data in keychain
    /// - Parameters:
    ///   - data: `Data` which needs to be saved
    ///   - key: `String` against unique identifier
    func save(_ data: Data, forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        /// Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status )
        }
    }
    
    /// In order to retrieve the data
    /// - Parameter key: `String` unique identifier
    /// - Returns: `Data?` returns the optional data
    func retrieve(forKey key: String) throws -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status != errSecItemNotFound else {
            return nil
        }
        
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        return result as? Data
    }
    
    /// In order to delete from keychain
    /// - Parameter key: `String` unique identifier
    func delete(forKey key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unknown(status)
        }
    }
    
    /// In order to save string
    /// - Parameters:
    ///   - string: `String` in order to convert string into data
    ///   - key: `String` unique identifier
    func saveString(_ string: String, forKey key: String) throws {
        guard let data = string.data(using: .utf8) else {
            throw KeychainError.invalidData
        }
        try save(data, forKey: key)
    }
    
    /// In order to retrive string
    /// - Parameter key: `String` unique identifier
    /// - Returns: `String?` optional data
    func retrieveString(forKey key: String) throws -> String? {
        guard let data = try retrieve(forKey: key) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

/// Enum for Keychain Errors
enum KeychainError: Error {
    case duplicateItem
    case unknown(OSStatus)
    case itemNotFound
    case invalidData
}
