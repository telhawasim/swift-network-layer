//
//  AuthInterceptor.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

final class AuthInterceptor: RetryableInterceptor {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private let tokenManager: TokenManagerProtocol
    
    // MARK: - INITIALIZER -
    init(tokenManager: TokenManagerProtocol) {
        self.tokenManager = tokenManager
    }
    
    func intercept(_ request: URLRequest, endpoint: any Endpoint) async throws -> URLRequest {
        guard endpoint.requiresAuthentication else { return request }
        
        var modified = request
        
        if let token = await tokenManager.getAccessToken() {
            modified.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return modified
    }
    
    func shouldRetry(error: NetworkError, retryCount: Int) async throws -> Bool {
        guard case .unauthorized = error, retryCount < 1 else {
            return false
        }
        
        do {
            try await tokenManager.refreshToken()
            return true
        } catch {
            await tokenManager.clearTokens()
            throw NetworkError.authenticationRequired
        }
    }
}
