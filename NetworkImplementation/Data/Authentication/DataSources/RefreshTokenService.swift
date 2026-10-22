//
//  RefreshTokenService.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

struct RefreshTokenService: TokenRefreshing {

    // MARK: - PROPERTIES -

    /// Dependencies
    private let client: any NetworkClientProtocol

    // MARK: - INITIALIZER -
    init(client: any NetworkClientProtocol) {
        self.client = client
    }

    func refresh(using refreshToken: String) async throws -> TokenPair {
        let request = try AuthAPI.refresh(RefreshTokenRequestDTO(refreshToken: refreshToken))
        let response = try await client.send(request)

        return TokenPair(
            accessToken: response.value.accessToken,
            refreshToken: response.value.refreshToken
        )
    }
}
