//
//  RequestAdapter.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Request Adapter Protocol
protocol RequestAdapterProtocol {
    func adapt(_ request: URLRequest) async throws -> URLRequest
}

class DefaultRequest: RequestAdapterProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let tokenManager: TokenManager
    
    // MARK: - INITIALIZER -
    init(tokenManager: TokenManager) {
        self.tokenManager = tokenManager
    }
    
    /// Add request adapter
    /// - Parameter request: `URLRequest` before added headers
    /// - Returns: `URLRequest` after adding headers
    func adapt(_ request: URLRequest) async throws -> URLRequest {
        var adaptedRequest = request
        
        /// Add authentication token if available
        if let token = try? await tokenManager.getAccessToken() {
            adaptedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        /// Add common headers
        adaptedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        adaptedRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return adaptedRequest
    }
}
