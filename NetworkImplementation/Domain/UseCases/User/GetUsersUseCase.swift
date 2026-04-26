//
//  GetUsersUseCase.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Get Users Use Case Protocol
protocol GetUsersUseCaseProtocol {
    func execute(limit: Int, skip: Int) async throws -> [User]
}

final class GetUsersUseCase: GetUsersUseCaseProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let repository: UserRepositoryProtocol
    
    // MARK: - INITIALIZER -
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(limit: Int = 30, skip: Int = 0) async throws -> [User] {
        return try await repository.getUsers(limit: limit, skip: skip)
    }
}
