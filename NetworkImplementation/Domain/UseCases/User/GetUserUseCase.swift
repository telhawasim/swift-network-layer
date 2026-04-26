//
//  GetUserUseCase.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Get User Use Case Protocol
protocol GetUserUseCaseProtocol {
    func execute(userId: Int) async throws -> User
}

final class GetUserUseCase: GetUserUseCaseProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let repository: UserRepositoryProtocol
    
    // MARK: - INITIALIZER -
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(userId: Int) async throws -> User {
        guard userId > 0 else {
            throw ValidationError.invalidUserId
        }
        
        return try await repository.getUser(id: userId)
    }
}
