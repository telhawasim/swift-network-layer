//
//  AuthRepositoryImpl.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct AuthRepositoryImpl: AuthRepositoryProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let remoteDataSource: any AuthRemoteDataSourceProtocol
    private let authSession: any AuthSessionProtocol
    private let mapper: AuthMapper

    // MARK: - INITALIZER -
    init(
        remoteDataSource: any AuthRemoteDataSourceProtocol,
        authSession: any AuthSessionProtocol,
        mapper: AuthMapper = AuthMapper()
    ) {
        self.remoteDataSource = remoteDataSource
        self.authSession = authSession
        self.mapper = mapper
    }
    
    func login(username: String, password: String) async throws -> AuthToken {
        let response = try await remoteDataSource.login(
            request: LoginRequestDTO(
                username: username,
                password: password
            )
        )

        try await authSession.store(
            TokenPair(accessToken: response.accessToken, refreshToken: response.refreshToken))

        return mapper.toDomain(response)
    }
    
    func logout() async {
        await authSession.logout()
    }
}
