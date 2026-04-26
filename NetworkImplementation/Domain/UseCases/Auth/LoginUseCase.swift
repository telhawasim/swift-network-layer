//
//  LoginUseCase.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Login Use Case Protocol
protocol LoginUseCaseProtocol {
    func execute(username: String, password: String) async throws -> AuthToken
}

final class LoginUseCase: LoginUseCaseProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let repository: AuthRepositoryProtocol
    
    // MARK: - INITIALIZER -
    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(username: String, password: String) async throws -> AuthToken {
        // Validate inputs
        guard !username.isEmpty else {
            throw ValidationError.emptyUsername
        }
        
        guard !password.isEmpty else {
            throw ValidationError.emptyPassword
        }
        
        return try await repository.login(username: username, password: password)
    }
}

enum ValidationError: Error {
    case emptyUsername
    case emptyPassword
    case invalidEmail
    case invalidUserId
    case emptySearchQuery
    
    var localizedDescription: String {
        switch self {
        case .emptyUsername: "Username cannot be empty"
        case .emptyPassword: "Password cannot be empty"
        case .invalidEmail: "Invalid email format"
        case .invalidUserId: "Invalid User ID"
        case .emptySearchQuery: "Search cannot be empty"
        }
    }
}
