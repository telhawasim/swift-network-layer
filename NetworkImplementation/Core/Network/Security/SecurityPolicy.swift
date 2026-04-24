//
//  SecurityPolicy.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

public struct SecurityPolicy: Sendable {
    public let tlsMinimumVersion: TLSVersion
    public let allowedCipherSuites: [String]
    public let requireHTTPS: Bool
    public let certificatePinningEnabled: Bool
    public let allowSelfSignedCertificates: Bool
    public let sessionTimeout: TimeInterval
    public let maxRetryCount: Int
    
    /// TLS Version
    public enum TLSVersion: Sendable {
        case tls12
        case tls13
        
        /// Comuted Properties
        var value: tls_protocol_version_t {
            switch self {
            case .tls12: return .TLSv12
            case .tls13: return .TLSv13
            }
        }
    }
    
    public static let `default` = SecurityPolicy(
        tlsMinimumVersion: .tls12,
        allowedCipherSuites: [],
        requireHTTPS: true,
        certificatePinningEnabled: true,
        allowSelfSignedCertificates: false,
        sessionTimeout: 30,
        maxRetryCount: 3
    )
    
    public static let strict = SecurityPolicy(
        tlsMinimumVersion: .tls13,
        allowedCipherSuites: [],
        requireHTTPS: true,
        certificatePinningEnabled: true,
        allowSelfSignedCertificates: false,
        sessionTimeout: 15,
        maxRetryCount: 1
    )
    
    public static let development = SecurityPolicy(
        tlsMinimumVersion: .tls12,
        allowedCipherSuites: [],
        requireHTTPS: false,
        certificatePinningEnabled: false,
        allowSelfSignedCertificates: true,
        sessionTimeout: 60,
        maxRetryCount: 5
    )
    
    // MARK: - INITIALIZER -
    public init(
        tlsMinimumVersion: TLSVersion,
        allowedCipherSuites: [String],
        requireHTTPS: Bool,
        certificatePinningEnabled: Bool,
        allowSelfSignedCertificates: Bool,
        sessionTimeout: TimeInterval,
        maxRetryCount: Int
    ) {
        self.tlsMinimumVersion = tlsMinimumVersion
        self.allowedCipherSuites = allowedCipherSuites
        self.requireHTTPS = requireHTTPS
        self.certificatePinningEnabled = certificatePinningEnabled
        self.allowSelfSignedCertificates = allowSelfSignedCertificates
        self.sessionTimeout = sessionTimeout
        self.maxRetryCount = maxRetryCount
    }
}
