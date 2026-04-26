//
//  ConfigurationError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import Foundation

enum ConfigurationError: Error {
    case missingKey(String)
    case invalidValue(String)
    case invalidType(String)
    case invalidPlistFormat
    
    var localizedDescription: String {
        switch self {
        case .missingKey(let key): "Missing configuration key: \(key)"
        case .invalidValue(let key): "Invalid value for key: \(key)"
        case .invalidType(let key): "Invalid type for key: \(key)"
        case .invalidPlistFormat: "Invalid Info.plist format"
        }
    }
}
