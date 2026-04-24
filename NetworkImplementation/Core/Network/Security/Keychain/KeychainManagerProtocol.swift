//
//  KeychainManagerProtocol.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

public protocol KeychainManagerProtocol: Sendable {
    func save<T: Codable & Sendable>(_ value: T, for key: String) async throws
    func retrieve<T: Codable & Sendable>(for key: String) async throws -> T
    func delete(for key: String) async throws
    func exists(for key: String) async -> Bool
    func clear() async throws
}
