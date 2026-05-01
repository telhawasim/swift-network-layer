//
//  UserLocalDataSource.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 01/05/2026.
//

import Foundation

protocol UserLocalDataSourceProtocol {
    func getUsers(limit: Int, skip: Int) async throws -> UsersResponseDTO?
    func saveUsers(_ response: UsersResponseDTO, limit: Int, skip: Int) async throws
    
    func getUser(id: Int) async throws -> UserDTO?
    func saveUser(_ user: UserDTO) async throws
}

final class UserLocalDataSource: UserLocalDataSourceProtocol {
    
    private let cacheManager: CacheManagerProtocol
    
    init(cacheManager: CacheManagerProtocol = CacheManager()) {
        self.cacheManager = cacheManager
    }
    
    func getUsers(limit: Int, skip: Int) async throws -> UsersResponseDTO? {
        return try cacheManager.get(forKey: "users_limit_\(limit)_skip_\(skip)")
    }
    
    func saveUsers(_ response: UsersResponseDTO, limit: Int, skip: Int) async throws {
        try cacheManager.set(response, forKey: "users_limit_\(limit)_skip_\(skip)", expiry: .hours(1))
    }
    
    func getUser(id: Int) async throws -> UserDTO? {
        return try cacheManager.get(forKey: "user_\(id)")
    }
    
    func saveUser(_ user: UserDTO) async throws {
        try cacheManager.set(user, forKey: "user_\(user.id)", expiry: .hours(24))
    }
}
