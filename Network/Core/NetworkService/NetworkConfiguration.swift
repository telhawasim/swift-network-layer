//
//  NetworkConfiguration.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

struct NetworkConfiguration {
    let baseURL: String
    let apiVersion: String
    let defaultHeaders: HTTPHeaders
    let defaultTimeout: TimeInterval
    let maxRetryCount: Int
    let retryDelay: TimeInterval
    let logLevel: NetworkLogLevel
    let sslPinningEnabled: Bool
    let certificateNames: [String]
    
    // MARK: - INITIALIZER -
    init(
        baseURL: String,
        apiVersion: String = "v1",
        defaultHeaders: HTTPHeaders = HTTPHeaders(),
        defaultTimeout: TimeInterval = 30,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1.0,
        logLevel: NetworkLogLevel = .verbose,
        sslPinningEnabled: Bool = false,
        certificateNames: [String] = []
    ) {
        self.baseURL = baseURL
        self.apiVersion = apiVersion
        self.defaultHeaders = defaultHeaders
        self.defaultTimeout = defaultTimeout
        self.maxRetryCount = maxRetryCount
        self.retryDelay = retryDelay
        self.logLevel = logLevel
        self.sslPinningEnabled = sslPinningEnabled
        self.certificateNames = certificateNames
    }
    
    static var `default`: NetworkConfiguration {
        NetworkConfiguration(baseURL: "https://api.example.com")
    }
}
