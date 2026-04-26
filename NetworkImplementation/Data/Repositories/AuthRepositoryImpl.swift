//
//  AuthRepositoryImpl.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let remoteDataSource: AuthRemoteDataSourceProtocol
    private let secureStorage: SecureStorage
    private let mapper: AuthMapperProtocol
    private let tokenManager: TokenManagerProtocol
    
    // MARK: - INITALIZER -
    init(
        remoteDataSource: AuthRemoteDataSourceProtocol,
        secureStorage: SecureStorage,
        mapper: AuthMapperProtocol = AuthMapper(),
        tokenManager: TokenManagerProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.secureStorage = secureStorage
        self.mapper = mapper
        self.tokenManager = tokenManager
    }
    
    func login(username: String, password: String) async throws -> AuthToken {
        let requestDTO = mapper.toDTO(username: username, password: password)
        let responseDTO = try await remoteDataSource.login(request: requestDTO)
        let authToken = mapper.toDomain(responseDTO)
        
        /// Save tokens securely
        try await tokenManager.saveAccessToken(authToken.accessToken)
        if !authToken.refreshToken.isEmpty {
            try await tokenManager.saveRefreshToken(authToken.refreshToken)
        }
        
        return authToken
    }
    
    func refreshToken() async throws -> AuthToken {
        guard let _ = try await tokenManager.getAccessToken() else {
            throw NetworkError.unauthorized
        }
        
        // I am using DummyJSON, it doesn't support token refresh, so I'll simulate it
        // In real implementation, you would call the refresh endpoint
        throw NetworkError.unauthorized
    }
    
    func logout() async throws {
        try await tokenManager.clearTokens()
    }
}
