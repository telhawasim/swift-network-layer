//
//  UserRemoteDataSource.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// User Remote Data soruce Protocol
protocol UserRemoteDataSourceProtocol {
    func getUsers(limit: Int, skip: Int) async throws -> UsersResponseDTO
    func getUser(id: Int) async throws -> UserDTO
    func searchUsers(query: String) async throws -> UsersResponseDTO
}

final class UserRemoteDataSource: UserRemoteDataSourceProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let networkService: NetworkServiceProtocol
    
    // MARK: - INITIALIZER -
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getUsers(limit: Int, skip: Int) async throws -> UsersResponseDTO {
        let endpoint = UserEndpoint.getUsers(limit: limit, skip: skip)
        return try await networkService.execute(endpoint)
    }
    
    func getUser(id: Int) async throws -> UserDTO {
        let endpoint = UserEndpoint.getUser(id: id)
        return try await networkService.execute(endpoint)
    }
    
    func searchUsers(query: String) async throws -> UsersResponseDTO {
        let endpoint = UserEndpoint.searchUsers(query: query)
        return try await networkService.execute(endpoint)
    }
}
