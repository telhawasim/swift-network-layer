//
//  AuthRepository.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Auth Repository Protocol
protocol AuthRepositoryProtocol {
    func login(username: String, password: String) async throws -> AuthToken
    func refreshToken() async throws -> AuthToken
    func logout() async throws
}
