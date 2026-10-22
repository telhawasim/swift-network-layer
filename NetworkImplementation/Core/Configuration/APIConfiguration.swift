//
//  APIConfiguration.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

struct APIConfiguration: Sendable {
    let baseURL: URL
    let timeout: TimeInterval
    let maximumRetryCount: Int
    let loggingEnabled: Bool
    let verboseLoggingEnabled: Bool
    let pinningConfiguration: PinningConfiguration

    static func live(bundle: Bundle = .main) throws -> APIConfiguration {
        guard let baseURLString = bundle.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
              let baseURL = URL(string: baseURLString),
              baseURL.scheme?.lowercased() == "https",
              baseURL.host != nil else {
            throw ConfigurationError.invalidValue("API_BASE_URL")
        }

        let timeout = (
            bundle.object(forInfoDictionaryKey: "API_TIMEOUT") as? NSNumber
        )?.doubleValue ?? 30
        let retryCount = (
            bundle.object(forInfoDictionaryKey: "MAX_RETRY_COUNT") as? NSNumber
        )?.intValue ?? 3
        let loggingEnabled = boolValue(for: "ENABLE_LOGGING", in: bundle)
        let verboseLoggingEnabled = boolValue(for: "VERBOSE_LOGGING", in: bundle)
        let pinningEnabled = boolValue(for: "ENABLE_SSL_PINNING", in: bundle)
        let pinnedHost = bundle.object(
            forInfoDictionaryKey: "SSL_PINNED_DOMAIN"
        ) as? String
        let pins = bundle.object(
            forInfoDictionaryKey: "SSL_CERTIFICATE_SHA256_PINS"
        ) as? [String] ?? []

        let pinsByHost: [String: Set<String>]

        if let pinnedHost, !pinnedHost.isEmpty {
            pinsByHost = [
                pinnedHost.lowercased(): Set(pins.filter { !$0.isEmpty && !$0.contains("$(") })
            ]
        } else {
            pinsByHost = [:]
        }

        return APIConfiguration(
            baseURL: baseURL,
            timeout: timeout,
            maximumRetryCount: retryCount,
            loggingEnabled: loggingEnabled,
            verboseLoggingEnabled: verboseLoggingEnabled,
            pinningConfiguration: try PinningConfiguration(
                enabled: pinningEnabled, pinsByHost: pinsByHost
            )
        )
    }

    private static func boolValue(for key: String, in bundle: Bundle) -> Bool {
        if let number = bundle.object(forInfoDictionaryKey: key) as? NSNumber {
            return number.boolValue
        }

        guard let value = bundle.object(forInfoDictionaryKey: key) as? String else {
            return false
        }

        return ["true", "yes", "1"].contains(value.lowercased())
    }
}
