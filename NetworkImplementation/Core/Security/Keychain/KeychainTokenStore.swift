//
//  KeychainTokenStore.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

actor KeychainTokenStore: TokenStore {

    /// Enum responsible for all cache state
    private enum CacheStore {
        case notLoaded
        case loaded(TokenPair?)
    }

    // MARK: - PROPERTIES -

    /// Normal
    private let keychain: KeychainManagerProtocol
    private let storageKey = "authenticated_token_pair"
    private var cacheState: CacheStore = .notLoaded

    // MARK: - INITIALIZER -
    init(keychain: KeychainManagerProtocol) {
        self.keychain = keychain
    }

    func load() async throws -> TokenPair? {
        if case .loaded(let cachedTokens) = cacheState {
            return cachedTokens
        }

        guard let data = try keychain.retrieve(forKey: storageKey) else {
            cacheState = .loaded(nil)
            return nil
        }

        let tokens = try JSONDecoder().decode(TokenPair.self, from: data)
        cacheState = .loaded(tokens)
        return tokens
    }

    func save(_ tokens: TokenPair) async throws {
        let data = try JSONEncoder().encode(tokens)
        try keychain.save(data, forKey: storageKey)
        cacheState = .loaded(tokens)
    }

    func clear() async throws {
        try keychain.delete(forKey: storageKey)
        cacheState = .loaded(nil)
    }
}
