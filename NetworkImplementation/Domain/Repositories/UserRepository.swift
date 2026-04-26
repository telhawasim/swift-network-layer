//
//  UserRepository.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// User Repository Protocol
protocol UserRepositoryProtocol {
    func getUsers(limit: Int, skip: Int) async throws -> [User]
    func getUser(id: Int) async throws -> User
    func searchUsers(query: String) async throws -> [User]
}
