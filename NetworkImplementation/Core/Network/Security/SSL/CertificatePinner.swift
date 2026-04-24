//
//  CertificatePinner.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation
import Security
import CryptoKit

public actor CertificatePinner: @unchecked Sendable {
    
    // MARK: - PROPERTIES -
    
    /// Normal
    private let pinnedDomains: [String: PinnerMode]
    private let logger: NetworkLoggerProtocol
    
    // MARK: - INITIALIZER -
    public init(
        pinnedDomains: [String: PinnerMode],
        logger: NetworkLoggerProtocol = NetworkLogger.shared
    ) {
        self.pinnedDomains = pinnedDomains
        self.logger = logger
    }
}

//// MARK: - CERTIFICATE PINNER PROTOCOL HELPER FUNCTIONS -
extension CertificatePinner: CertificatePinnerProtocol {
    
    public func validate(_ challenge: URLAuthenticationChallenge) async -> Bool {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust,
              let host = challenge.protectionSpace.host as String? else {
            return false
        }
        
        guard let pinningMode = findPinningMode(for: host) else {
            /// No pinning configured for this host, allow by default
            return true
        }
        
        switch pinningMode {
        case .disabled:
            return true
        
        case .certificate(let pinnedCerts):
            return validateCertificates(serverTrust: serverTrust, pinnedCerts: pinnedCerts, host: host)
            
        case .publicKey(let pinnedKeys):
            return validatePublicKeys(serverTrust: serverTrust, pinnedKeys: pinnedKeys, host: host)
        }
    }
}

// MARK: - HELPER FUNCTIONS -
extension CertificatePinner {
    
    /// In order to find the pinning mode
    /// - Parameter host: `String` server host
    /// - Returns: `PinnerMode?` will return pinner mode
    private func findPinningMode(for host: String) -> PinnerMode? {
        /// Extract match
        if let mode = pinnedDomains[host] {
            return mode
        }
        
        /// Wildcard match
        let components = host.split(separator: ".")
        if components.count > 2 {
            let wildcard = "*." + components.dropFirst().joined(separator: ".")
            return pinnedDomains[wildcard]
        }
        
        return nil
    }
    
    /// In order to validate certificates
    /// - Parameters:
    ///   - serverTrust: `SecTrust` trust from server
    ///   - pinnedCerts: `Set<String>` pinned certificates
    ///   - host: `String` server host
    /// - Returns: `Bool` return `true` if validated, otherwise `false`
    private func validateCertificates(
        serverTrust: SecTrust,
        pinnedCerts: Set<String>,
        host: String
    ) -> Bool {
        guard let certificates = serverCertificates(from: serverTrust) else {
            logger.log("Failed to get certificates from server trust", level: .error)
            return false
        }
        
        for cert in certificates {
            let certData = SecCertificateCopyData(cert) as Data
            let certBase64 = certData.base64EncodedString()
            
            if pinnedCerts.contains(certBase64) {
                logger.log("Certificate pinning succeeded for host: \(host)", level: .info)
                return true
            }
        }
        
        logger.log("Certificate pinning failed for host: \(host)", level: .error)
        return false
    }
    
    /// In order to validate the public keys
    /// - Parameters:
    ///   - serverTrust: `SecTrust` trust from server
    ///   - pinnedKeys: `Set<String>` pinned keys
    ///   - host: `String` server host
    /// - Returns: `Bool` return `true` if validated, otherwise `false`
    private func validatePublicKeys(
        serverTrust: SecTrust,
        pinnedKeys: Set<String>,
        host: String
    ) -> Bool {
        guard let certificates = serverCertificates(from: serverTrust) else {
            logger.log("Failed to get certificates from server trust", level: .error)
            return false
        }
        
        for cert in certificates {
            if let publicKeyHash = extractPublicKeyHash(from: cert) {
                if pinnedKeys.contains(publicKeyHash) {
                    logger.log("Public key pinning successed for host: \(host)", level: .info)
                    return true
                }
            }
        }
        
        logger.log("Public key pinning failed for host: \(host)", level: .error)
        return false
    }
    
    /// In order to get server certificates
    /// - Parameter trust: `SecTrust` trust
    /// - Returns: `[SecCertificate]?` array of certificates
    private func serverCertificates(from trust: SecTrust) -> [SecCertificate]? {
        var certificates: [SecCertificate] = []
        
        if let certChain = SecTrustCopyCertificateChain(trust) as? [SecCertificate] {
            certificates = certChain
        }
        
        return certificates.isEmpty ? nil : certificates
    }
    
    /// In order to extract public key hash
    /// - Parameter certificate: `SecCertificate` extract from certificate
    /// - Returns: `String?` public key
    private func extractPublicKeyHash(from certificate: SecCertificate) -> String? {
        guard let publicKey = SecCertificateCopyKey(certificate),
              let publicKeyData = SecKeyCopyExternalRepresentation(publicKey, nil) as Data? else {
            return nil
        }
        
        /// Add SubjectPublicKeyInfo header for RSA 2048
        let rsa2048Header: [UInt8] = [
            0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09,
            0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
            0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
        ]
        
        var dataToHash = Data(rsa2048Header)
        dataToHash.append(publicKeyData)
        
        let hash = SHA256.hash(data: dataToHash)
        return Data(hash).base64EncodedString()
    }
}
