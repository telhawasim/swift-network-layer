//
//  RefreshTokenUseCase.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Refresh Token Use Case Protocol
protocol RefreshTokenUseCaseProtocol {
    func execute() async throws -> AuthToken
}

final class RefreshTokenUseCase: RefreshTokenUseCaseProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let repository: AuthRepositoryProtocol
    
    // MARK: - INITIALIZER -
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - INITIALIZER -
    func execute() async throws -> AuthToken {
        return try await repository.refreshToken()
    }
}
