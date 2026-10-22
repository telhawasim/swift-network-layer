//
//  CacheStore.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

protocol CacheStore: Sendable {
    func value<Value>(
        forKey key: String,
        as type: Value.Type
    ) async throws -> Value? where Value: Codable & Sendable

    func insert<Value>(
        _ value: Value,
        forKey key: String,
        expiry: CacheExpiry
    ) async throws where Value: Codable & Sendable

    func remove(forKey key: String) async throws
    func removeAll() async throws
}
