//
//  APIConfiguration.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct APIConfiguration {
    private static let config = ConfigurationManager.shared
    
    // Base Configuration
    static var baseURL: String {
        return config.apiBaseURL
    }
    
    static var apiKey: String? {
        return config.apiKey
    }
    
    static var apiSecret: String? {
        return config.apiSecret
    }
    
    static var timeout: TimeInterval {
        return config.apiTimeout
    }
    
    static var maxRetryCount: Int {
        return config.maxRetryCount
    }
    
    // Environment
    static var environment: Environment {
        return config.currentEnvironment
    }
    
    static var isProduction: Bool {
        return environment.isProduction
    }
    
    static var isDebug: Bool {
        return environment.isDebug
    }
    
    // SSL Pinning Configuration
    static var enableSSLPinning: Bool {
        return config.enableSSLPinning
    }
    
    static var pinnedDomains: Set<String> {
        return config.sslPinnedDomains
    }
    
    // Logging
    static var enableNetworkLogging: Bool {
        return config.enableLogging
    }
    
    static var isVerboseLogging: Bool {
        #if DEBUG
        return true
        #else
        return config.optionalBool(forKey: "VERBOSE_LOGGING") ?? false
        #endif
    }
    
    // App Information
    static var appVersion: String {
        return config.appVersion
    }
    
    static var buildNumber: String {
        return config.buildNumber
    }
    
    static var bundleIdentifier: String {
        return config.bundleIdentifier
    }
    
    // Headers
    static var defaultHeaders: [String: String] {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "App-Version": appVersion,
            "App-Build": buildNumber,
            "Platform": "iOS"
        ]
        
        if let apiKey = apiKey {
            headers["X-API-Key"] = apiKey
        }
        
        return headers
    }
    
    // Feature Flags
    static var enableAnalytics: Bool {
        return config.optionalBool(forKey: ConfigurationManager.Keys.enableAnalytics) ?? false
    }
    
    static var enableCrashReporting: Bool {
        return config.optionalBool(forKey: ConfigurationManager.Keys.enableCrashReporting) ?? true
    }
    
    // Print configuration (Debug only)
    static func printConfiguration() {
        config.printAllConfigurations()
    }
}
