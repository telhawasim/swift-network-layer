//
//  AuthRemoteDataSource.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Auth Remote Datasource Protocol
protocol AuthRemoteDataSourceProtocol {
    func login(request: LoginRequestDTO) async throws -> LoginResponseDTO
    func getCurrentUser(token: String) async throws -> UserDTO
}

final class AuthRemoteDataSource: AuthRemoteDataSourceProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let networkService: NetworkServiceProtocol
    
    // MARK: - INIITALIZER -
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func login(request: LoginRequestDTO) async throws -> LoginResponseDTO {
        let endpoint = AuthEndpoint.login(request: request)
        return try await networkService.execute(endpoint)
    }
    
    func getCurrentUser(token: String) async throws -> UserDTO {
        let endpoint = AuthEndpoint.getCurrentUser
        return try await networkService.execute(endpoint)
    }
}
