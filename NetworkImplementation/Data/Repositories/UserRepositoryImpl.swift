//
//  UserRepositoryImpl.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

final class UserRepositoryImpl: UserRepositoryProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let remoteDataSource: UserRemoteDataSourceProtocol
    private let mapper: UserMapperProtocol
    
    // MARK: - INITIALIZER -
    init(
        remoteDataSource: UserRemoteDataSourceProtocol,
        mapper: UserMapperProtocol = UserMapper()
    ) {
        self.remoteDataSource = remoteDataSource
        self.mapper = mapper
    }
    
    func getUsers(limit: Int, skip: Int) async throws -> [User] {
        let response = try await remoteDataSource.getUsers(limit: limit, skip: skip)
        return mapper.toDomainArray(response.users)
    }
    
    func getUser(id: Int) async throws -> User {
        let response = try await remoteDataSource.getUser(id: id)
        return mapper.toDomain(response)
    }
    
    func searchUsers(query: String) async throws -> [User] {
        let response = try await remoteDataSource.searchUsers(query: query)
        return mapper.toDomainArray(response.users)
    }
}
