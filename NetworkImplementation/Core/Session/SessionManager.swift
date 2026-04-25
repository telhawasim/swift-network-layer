//
//  SessionManager.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

final class SessionManager {
    
    // MARK: - PROPERTIES -
    
    /// Singleton
    static let shared = SessionManager()
    
    /// Dependencies
    private var session: URLSession?
    private let sslPinningManager: SSLPinningManagerProtocol?
    private let configuration: URLSessionConfiguration
    
    // MARK: - INITIALIZER -
    init(
        configuration: URLSessionConfiguration = .default,
        enableSSLPinning: Bool = false,
        pinnedDomains: Set<String> = [],
        certificates: [Data] = []
    ) {
        self.configuration = configuration
        self.configuration.timeoutIntervalForRequest = 30
        self.configuration.timeoutIntervalForResource = 300
        self.configuration.waitsForConnectivity = true
        self.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        if enableSSLPinning {
            self.sslPinningManager = SSLPinningManager(
                certificates: certificates,
                pinnedDomains: pinnedDomains,
                validationMode: .publicKey
            )
        } else {
            self.sslPinningManager = nil
        }
        
        createSession()
    }
    
    /// In order to get url session
    /// - Returns: `URLSession` return session
    func getSession() -> URLSession {
        if let session = session {
            return session
        }
        createSession()
        return session!
    }
    
    /// In order to invalidate session
    func invalidateSession() {
        session?.invalidateAndCancel()
        session = nil
    }
    
    /// In order to recreate session
    func recreateSession() {
        invalidateSession()
        createSession()
    }
}

// MARK: - HELPER FUNCTIONS -
extension SessionManager {
    
    /// In order to create the session
    private func createSession() {
        if let sslPinningManager = sslPinningManager {
            session = URLSession(
                configuration: configuration,
                delegate: sslPinningManager,
                delegateQueue: nil
            )
        } else {
            session = URLSession(configuration: configuration)
        }
    }
}
