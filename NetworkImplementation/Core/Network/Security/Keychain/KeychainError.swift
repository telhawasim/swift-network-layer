//
//  KeychainError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

/// Enum for keychain errors
public enum KeychainError: Error, Sendable, LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidData
    case unexpectedStatus(OSStatus)
    case encodingFailed
    case decodingFailed
    
    /// Computed Properties
    public var errorDescription: String? {
        switch self {
        case .itemNotFound: "Keychain item not found"
        case .duplicateItem: "Keychain item already exists"
        case .invalidData: "Invalid keychain data"
        case .unexpectedStatus(let oSStatus): "Keychain error with status: \(oSStatus)"
        case .encodingFailed: "Failed to encode keychain data"
        case .decodingFailed: "Failed to decode keychain data"
        }
    }
}
