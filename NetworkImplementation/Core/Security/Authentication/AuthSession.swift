//
//  AuthSession.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

actor AuthSession: AuthSessionProtocol {

    // MARK: - PROPERTIES -

    /// Dependencies
    private let tokenStore: any TokenStore
    private let tokenRefresher: TokenRefreshing
    /// Normal
    private var refreshTask: Task<String, Error>?

    // MARK: - INITIALIZER -
    init(tokenStore: any TokenStore, tokenRefresher: any TokenRefreshing) {
        self.tokenStore = tokenStore
        self.tokenRefresher = tokenRefresher
    }

    func accessToken() async throws -> String? {
        try await tokenStore.load()?.accessToken
    }

    func store(_ tokens: TokenPair) async throws {
        try await tokenStore.save(tokens)
    }

    func refreshAccessToken(rejectedAccessToken: String?) async throws -> String {
        /*
         Another request may already have refreshed the token while this request was waiting
         for its 401 response.
        */
        if let rejectedAccessToken,
           let currentToken = try await tokenStore.load()?.accessToken,
           currentToken != rejectedAccessToken {
            return currentToken
        }

        // Share an in-progress refresh between concurrent requests.
        if let refreshTask {
            return try await refreshTask.value
        }

        let tokenStore = self.tokenStore
        let tokenRefresher = self.tokenRefresher

        let task = Task<String, Error> {
            guard let tokens = try await tokenStore.load(),
                  !tokens.refreshToken.isEmpty else {
                throw AuthSessionError.missingRefreshToken
            }

            let refreshedTokens = try await tokenRefresher.refresh(using: tokens.refreshToken)

            try await tokenStore.save(refreshedTokens)
            return refreshedTokens.accessToken
        }

        refreshTask = task
        defer { refreshTask = nil }

        do {
            return try await task.value
        } catch {
            try? await tokenStore.clear()
            throw AuthSessionError.refreshFailed
        }
    }

    func logout() async {
        refreshTask?.cancel()
        refreshTask = nil
        try? await tokenStore.clear()
    }
}
