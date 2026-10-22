//
//  AuthRemoteDataSource.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Auth Remote Datasource Protocol
protocol AuthRemoteDataSourceProtocol: Sendable {
    func login(request: LoginRequestDTO) async throws -> LoginResponseDTO
    func currentUser() async throws -> UserDTO
}

final class AuthRemoteDataSource: AuthRemoteDataSourceProtocol, Sendable {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let client: any NetworkClientProtocol

    // MARK: - INIITALIZER -
    init(client: NetworkClientProtocol) {
        self.client = client
    }
    
    func login(request: LoginRequestDTO) async throws -> LoginResponseDTO {
        try await client.send(AuthAPI.login(request)).value
    }
    
    func currentUser() async throws -> UserDTO {
        try await client.send(AuthAPI.currentUser()).value
    }
}
