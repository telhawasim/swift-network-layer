//
//  AuthSessionProtocol.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Protocol responsible for Auth Session
protocol AuthSessionProtocol: Sendable {
    func accessToken() async throws -> String?
    func store(_ tokens: TokenPair) async throws
    func refreshAccessToken(rejectedAccessToken: String?) async throws -> String
    func logout() async
}
