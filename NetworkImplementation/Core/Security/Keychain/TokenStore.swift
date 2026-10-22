//
//  TokenStore.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Protocol responsible for tokens operations
protocol TokenStore: Sendable {
    func load() async throws -> TokenPair?
    func save(_ tokens: TokenPair) async throws
    func clear() async throws
}
