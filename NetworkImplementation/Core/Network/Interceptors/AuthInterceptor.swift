//
//  AuthInterceptor.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Auth Interceptor Protocol
protocol AuthInterceptorProtocol {
    func retry(_ request: URLRequest, dueTo error: NetworkError) async throws -> URLRequest
}

final class AuthInterceptor {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let tokenManager: TokenManagerProtocol
    private let refreshTokenUseCase: RefreshTokenUseCaseProtocol
    
    /// Normal
    private var isRefreshing = false
    private var refreshTask: Task<String, Error>?
    
    // MARK: - INITIALIZER -
    init(tokenManager: TokenManagerProtocol, refreshTokenUseCase: RefreshTokenUseCaseProtocol) {
        self.tokenManager = tokenManager
        self.refreshTokenUseCase = refreshTokenUseCase
    }
}

// MARK: - AUTH INTERCEPTOR PROTOCOL FUNCTIONS -
extension AuthInterceptor: AuthInterceptorProtocol {
    
    /// In order to get and append token
    /// - Parameters:
    ///   - request: `URLRequest` request in which token header will be appended
    ///   - error: `NetworkError` in order to check error is `unauthorized`
    /// - Returns: `URLRequest` will return new url request
    func retry(_ request: URLRequest, dueTo error: NetworkError) async throws -> URLRequest {
        guard case .unauthorized = error else {
            throw error
        }
        
        /// Get new token
        let newToken = try await getRefreshedToken()
        
        /// Modify request with new token
        var retriedRequest = request
        retriedRequest.setValue("Bearer \(newToken)", forHTTPHeaderField: "Authorization")
        
        return retriedRequest
    }
}

// MARK: - HELPER FUNCTIONS -
extension AuthInterceptor {
    
    /// In order to get refreshed token
    /// - Returns: `String` return token
    private func getRefreshedToken() async throws -> String {
        /// If already refreshing, wait for that task
        if let existingTask = refreshTask {
            return try await existingTask.value
        }
        
        /// Create new refresh task
        let task = Task<String, Error> {
            defer { refreshTask = nil }
            
            let authToken = try await refreshTokenUseCase.execute()
            return authToken.accessToken
        }
        
        refreshTask = task
        return try await task.value
    }
}
