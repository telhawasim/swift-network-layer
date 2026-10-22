//
//  TokenRefreshing.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

/// Protocol for refreshing the token
protocol TokenRefreshing: Sendable {
    func refresh(using refreshToken: String) async throws -> TokenPair
}
