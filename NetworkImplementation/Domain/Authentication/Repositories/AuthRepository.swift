//
//  AuthRepository.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Auth Repository Protocol
protocol AuthRepositoryProtocol: Sendable {
    func login(username: String, password: String) async throws -> AuthToken
    func logout() async
}
