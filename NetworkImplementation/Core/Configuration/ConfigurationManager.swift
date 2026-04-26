//
//  ConfigurationManager.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import Foundation

protocol ConfigurationManagerProtocol {
    func string(forKey key: String) throws -> String
    func int(forKey key: String) throws -> Int
    func bool(forKey key: String) throws -> Bool
    func double(forKey key: String) throws -> Double
    func array(forKey key: String) throws -> [Any]
    func dictionary(forKey key: String) throws -> [String: Any]
    func optionalString(forKey key: String) -> String?
    func optionalInt(forKey key: String) -> Int?
    func optionalBool(forKey key: String) -> Bool?
}

final class ConfigurationManager: ConfigurationManagerProtocol {
    static let shared = ConfigurationManager()
    
    private let bundle: Bundle
    private var cache: [String: Any] = [:]
    private let cacheQueue = DispatchQueue(label: "com.app.configuration.cache", attributes: .concurrent)
    
    // MARK: - Configuration Keys
    struct Keys {
        // API Configuration
        static let apiBaseURL = "API_BASE_URL"
        static let apiKey = "API_KEY"
        static let apiSecret = "API_SECRET"
        static let apiTimeout = "API_TIMEOUT"
        
        // Environment
        static let environment = "ENVIRONMENT"
        static let appVersion = "CFBundleShortVersionString"
        static let buildNumber = "CFBundleVersion"
        static let bundleIdentifier = "CFBundleIdentifier"
        
        // Features
        static let enableSSLPinning = "ENABLE_SSL_PINNING"
        static let enableLogging = "ENABLE_LOGGING"
        static let enableAnalytics = "ENABLE_ANALYTICS"
        static let enableCrashReporting = "ENABLE_CRASH_REPORTING"
        
        // SSL Pinning
        static let sslPinnedDomains = "SSL_PINNED_DOMAINS"
        static let sslCertificates = "SSL_CERTIFICATES"
        
        // Third Party
        static let firebaseEnabled = "FIREBASE_ENABLED"
        static let mixpanelToken = "MIXPANEL_TOKEN"
        static let sentryDSN = "SENTRY_DSN"
        
        // App Configuration
        static let maxRetryCount = "MAX_RETRY_COUNT"
        static let cacheExpiration = "CACHE_EXPIRATION"
        static let sessionTimeout = "SESSION_TIMEOUT"
    }
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
        preloadCommonConfigurations()
    }
    
    // MARK: - Public Methods
    
    func string(forKey key: String) throws -> String {
        if let cached = getCached(key: key) as? String {
            return cached
        }
        
        guard let value = bundle.object(forInfoDictionaryKey: key) as? String else {
            throw ConfigurationError.missingKey(key)
        }
        
        guard !value.isEmpty else {
            throw ConfigurationError.invalidValue(key)
        }
        
        setCached(key: key, value: value)
        return value
    }
    
    func int(forKey key: String) throws -> Int {
        if let cached = getCached(key: key) as? Int {
            return cached
        }
        
        guard let value = bundle.object(forInfoDictionaryKey: key) else {
            throw ConfigurationError.missingKey(key)
        }
        
        if let intValue = value as? Int {
            setCached(key: key, value: intValue)
            return intValue
        }
        
        if let stringValue = value as? String, let intValue = Int(stringValue) {
            setCached(key: key, value: intValue)
            return intValue
        }
        
        throw ConfigurationError.invalidType(key)
    }
    
    func bool(forKey key: String) throws -> Bool {
        if let cached = getCached(key: key) as? Bool {
            return cached
        }
        
        guard let value = bundle.object(forInfoDictionaryKey: key) else {
            throw ConfigurationError.missingKey(key)
        }
        
        if let boolValue = value as? Bool {
            setCached(key: key, value: boolValue)
            return boolValue
        }
        
        if let stringValue = value as? String {
            let lowercased = stringValue.lowercased()
            if lowercased == "true" || lowercased == "yes" || lowercased == "1" {
                setCached(key: key, value: true)
                return true
            }
            if lowercased == "false" || lowercased == "no" || lowercased == "0" {
                setCached(key: key, value: false)
                return false
            }
        }
        
        if let intValue = value as? Int {
            let boolValue = intValue != 0
            setCached(key: key, value: boolValue)
            return boolValue
        }
        
        throw ConfigurationError.invalidType(key)
    }
    
    func double(forKey key: String) throws -> Double {
        if let cached = getCached(key: key) as? Double {
            return cached
        }
        
        guard let value = bundle.object(forInfoDictionaryKey: key) else {
            throw ConfigurationError.missingKey(key)
        }
        
        if let doubleValue = value as? Double {
            setCached(key: key, value: doubleValue)
            return doubleValue
        }
        
        if let stringValue = value as? String, let doubleValue = Double(stringValue) {
            setCached(key: key, value: doubleValue)
            return doubleValue
        }
        
        throw ConfigurationError.invalidType(key)
    }
    
    func array(forKey key: String) throws -> [Any] {
        if let cached = getCached(key: key) as? [Any] {
            return cached
        }
        
        guard let value = bundle.object(forInfoDictionaryKey: key) as? [Any] else {
            throw ConfigurationError.missingKey(key)
        }
        
        setCached(key: key, value: value)
        return value
    }
    
    func dictionary(forKey key: String) throws -> [String: Any] {
        if let cached = getCached(key: key) as? [String: Any] {
            return cached
        }
        
        guard let value = bundle.object(forInfoDictionaryKey: key) as? [String: Any] else {
            throw ConfigurationError.missingKey(key)
        }
        
        setCached(key: key, value: value)
        return value
    }
    
    // MARK: - Optional Methods
    
    func optionalString(forKey key: String) -> String? {
        return try? string(forKey: key)
    }
    
    func optionalInt(forKey key: String) -> Int? {
        return try? int(forKey: key)
    }
    
    func optionalBool(forKey key: String) -> Bool? {
        return try? bool(forKey: key)
    }
    
    func optionalDouble(forKey key: String) -> Double? {
        return try? double(forKey: key)
    }
    
    func optionalArray(forKey key: String) -> [Any]? {
        return try? array(forKey: key)
    }
    
    func optionalDictionary(forKey key: String) -> [String: Any]? {
        return try? dictionary(forKey: key)
    }
    
    // MARK: - Convenience Methods
    
    var currentEnvironment: Environment {
        guard let envString = try? string(forKey: Keys.environment),
              let environment = Environment(rawValue: envString) else {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
        return environment
    }
    
    var appVersion: String {
        return (try? string(forKey: Keys.appVersion)) ?? "1.0.0"
    }
    
    var buildNumber: String {
        return (try? string(forKey: Keys.buildNumber)) ?? "1"
    }
    
    var bundleIdentifier: String {
        return (try? string(forKey: Keys.bundleIdentifier)) ?? "com.app.unknown"
    }
    
    var apiBaseURL: String {
        guard let url = try? string(forKey: Keys.apiBaseURL) else {
            fatalError("API Base URL must be configured in Info.plist")
        }
        return url
    }
    
    var apiKey: String? {
        return optionalString(forKey: Keys.apiKey)
    }
    
    var apiSecret: String? {
        return optionalString(forKey: Keys.apiSecret)
    }
    
    var apiTimeout: TimeInterval {
        return TimeInterval(optionalInt(forKey: Keys.apiTimeout) ?? 30)
    }
    
    var enableSSLPinning: Bool {
        return optionalBool(forKey: Keys.enableSSLPinning) ?? false
    }
    
    var enableLogging: Bool {
        #if DEBUG
        return optionalBool(forKey: Keys.enableLogging) ?? true
        #else
        return optionalBool(forKey: Keys.enableLogging) ?? false
        #endif
    }
    
    var sslPinnedDomains: Set<String> {
        guard let domains = optionalArray(forKey: Keys.sslPinnedDomains) as? [String] else {
            return []
        }
        return Set(domains)
    }
    
    var maxRetryCount: Int {
        return optionalInt(forKey: Keys.maxRetryCount) ?? 3
    }
    
    // MARK: - Cache Management
    
    private func getCached(key: String) -> Any? {
        return cacheQueue.sync {
            return cache[key]
        }
    }
    
    private func setCached(key: String, value: Any) {
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.cache[key] = value
        }
    }
    
    func clearCache() {
        cacheQueue.async(flags: .barrier) { [weak self] in
            self?.cache.removeAll()
        }
    }
    
    private func preloadCommonConfigurations() {
        // Preload commonly used configurations
        _ = currentEnvironment
        _ = appVersion
        _ = buildNumber
        _ = bundleIdentifier
    }
    
    // MARK: - Debug
    
    func printAllConfigurations() {
        #if DEBUG
        print("========== Configuration ==========")
        print("Environment: \(currentEnvironment.rawValue)")
        print("App Version: \(appVersion)")
        print("Build Number: \(buildNumber)")
        print("Bundle ID: \(bundleIdentifier)")
        print("API Base URL: \(apiBaseURL)")
        print("SSL Pinning Enabled: \(enableSSLPinning)")
        print("Logging Enabled: \(enableLogging)")
        print("API Timeout: \(apiTimeout)")
        print("Max Retry Count: \(maxRetryCount)")
        if !sslPinnedDomains.isEmpty {
            print("SSL Pinned Domains: \(sslPinnedDomains)")
        }
        print("===================================")
        #endif
    }
}

// MARK: - Type-Safe Configuration Protocol

protocol AppConfiguration {
    var apiBaseURL: String { get }
    var apiKey: String? { get }
    var enableSSLPinning: Bool { get }
    var enableLogging: Bool { get }
    var environment: Environment { get }
}

extension ConfigurationManager: AppConfiguration {
    var environment: Environment {
        return currentEnvironment
    }
}
