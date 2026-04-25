//
//  SSLPinningManager.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// SSL Pinning Manager Protocol
protocol SSLPinningManagerProtocol: URLSessionDelegate {
    func validate(challenge: URLAuthenticationChallenge) -> Bool
}

final class SSLPinningManager: NSObject {
    
    // MARK: - PROPERTIES -
    
    /// Normal
    private let certificates: [Data]
    private let publicKeys: [SecKey]
    private let pinnedDomains: Set<String>
    private let validationMode: ValidationMode
    
    /// Enum for validation mode
    enum ValidationMode {
        case certificate
        case publicKey
        case both
    }
    
    // MARK: - INITIALIZER -
    init(
        certificates: [Data] = [],
        pinnedDomains: Set<String> = [],
        validationMode: ValidationMode = .publicKey
    ) {
        self.certificates = certificates
        self.publicKeys = certificates.compactMap { SSLPinningManager.extractPublicKey(from: $0) }
        self.pinnedDomains = pinnedDomains
        self.validationMode = validationMode
        super.init()
    }
}

// MARK: - SSL PINNING MANAGER PROTOCOL FUNCTIONS -
extension SSLPinningManager: SSLPinningManagerProtocol {
    
    /// In order to validate the ssl pinning
    /// - Parameter challenge: `URlAuthenticationChallenge` receiving data from server as trust
    /// - Returns: `Bool` if trusted, `true` otherwise `false`
    func validate(challenge: URLAuthenticationChallenge) -> Bool {
        guard let serverTrust = challenge.protectionSpace.serverTrust,
              pinnedDomains.contains(challenge.protectionSpace.host) else {
            return true
        }
        
        switch validationMode {
        case .certificate:
            return validateCertificate(serverTrust: serverTrust)
        case .publicKey:
            return validatePublicKey(serverTrust: serverTrust)
        case .both:
            return validateCertificate(serverTrust: serverTrust) && validatePublicKey(serverTrust: serverTrust)
        }
    }
}

// MARK: - HELPER FUNCTIONS -
extension SSLPinningManager {
    
    /// In order to validate certificates
    /// - Parameter serverTrust: `SecTrust` server trust
    /// - Returns: `Bool` if validated `true`, otherwise `false`
    private func validateCertificate(serverTrust: SecTrust) -> Bool {
        var result = SecTrustResultType.invalid
        SecTrustEvaluate(serverTrust, &result)
        
        let isValid = result == .unspecified || result == .proceed
        guard isValid else { return false }
        
        let serverCertificates = extractCertificates(from: serverTrust)
        
        for serverCert in serverCertificates {
            if certificates.contains(serverCert) {
                return true
            }
        }
        
        return false
    }
    
    /// In order to validate public keys
    /// - Parameter serverTrust: `SecTrust` server trust
    /// - Returns: `Bool` if validated `true`, otherwise `false`
    private func validatePublicKey(serverTrust: SecTrust) -> Bool {
        var result = SecTrustResultType.invalid
        SecTrustEvaluate(serverTrust, &result)
        
        let isValid = result == .unspecified || result == .proceed
        guard isValid else { return false }
        
        let serverKeys = extractPublicKeys(from: serverTrust)
        
        for serverKey in serverKeys {
            for pinnedKey in publicKeys {
                if keysMatch(serverKey, pinnedKey) {
                    return true
                }
            }
        }
        
        return false
    }
    
    /// In order to extract certificates
    /// - Parameter serverTrust: `SecTruts` server trust
    /// - Returns: `[Data]` array of certificates
    private func extractCertificates(from serverTrust: SecTrust) -> [Data] {
        var certificates: [Data] = []
        
        let count = SecTrustGetCertificateCount(serverTrust)
        for i in 0..<count {
            if let certificate = SecTrustGetCertificateAtIndex(serverTrust, i) {
                certificates.append(SecCertificateCopyData(certificate) as Data)
            }
        }
        
        return certificates
    }
    
    /// In order to extract multiple keys
    /// - Parameter serverTrust: `SecTrust` server trust
    /// - Returns: `[SecKey]` return array of keys
    private func extractPublicKeys(from serverTrust: SecTrust) -> [SecKey] {
        var publicKeys: [SecKey] = []
        
        let count = SecTrustGetCertificateCount(serverTrust)
        for i in 0..<count {
            if let certificate = SecTrustGetCertificateAtIndex(serverTrust, i),
               let publicKey = Self.extractPublicKey(from: SecCertificateCopyData(certificate) as Data) {
                publicKeys.append(publicKey)
            }
        }
        
        return publicKeys
    }
    
    /// In order to extract public key
    /// - Parameter certificateData: `Data` from which data will be extracted
    /// - Returns: `SecKey?` optional key value
    private static func extractPublicKey(from certificateData: Data) -> SecKey? {
        guard let certificate = SecCertificateCreateWithData(nil, certificateData as CFData) else {
            return nil
        }
        
        var publicKey: SecKey?
        
        if #available(iOS 14.0, *) {
            publicKey = SecCertificateCopyKey(certificate)
        } else {
            let policy = SecPolicyCreateBasicX509()
            var trust: SecTrust?
            SecTrustCreateWithCertificates(certificate, policy, &trust)
            
            if let trust = trust {
                var result = SecTrustResultType.invalid
                SecTrustEvaluate(trust, &result)
                publicKey = SecTrustCopyPublicKey(trust)
            }
        }
        
        return publicKey
    }
    
    /// In order to match keys
    /// - Parameters:
    ///   - key1: `SecKey` first key
    ///   - key2: `SecKey` second key
    /// - Returns: `Bool` return `true` in case matched, otherwise `false`
    private func keysMatch(_ key1: SecKey, _ key2: SecKey) -> Bool {
        guard let data1 = SecKeyCopyExternalRepresentation(key1, nil) as Data?,
              let data2 = SecKeyCopyExternalRepresentation(key2, nil) as Data? else {
            return false
        }
        return data1 == data2
    }
}

// MARK: - URL SESSION DELEGATE METHODS -
extension SSLPinningManager: URLSessionDelegate {
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        
        if validate(challenge: challenge),
           let serverTrust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
