//
//  DiskCacheStore.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation
import CryptoKit

actor DiskCacheStore: CacheStore {

    private struct Entry<Value: Codable>: Codable {
        let value: Value
        let expirationDate: Date?

        var isExpired: Bool {
            expirationDate.map { Date() >= $0 } ?? false
        }
    }

    // MARK: - PROPERTIES -

    /// Normal
    private let fileManager: FileManager
    private let directory: URL

    // MARK: - INITIALIZER -
    init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager

        let cachesDirectory = try fileManager.url(
            for: .cachesDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        directory = cachesDirectory.appendingPathComponent("NetworkCache", isDirectory: true)

        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }

    func value<Value>(
        forKey key: String,
        as type: Value.Type
    ) async throws -> Value? where Value: Codable & Sendable {
        let url = fileURL(for: key)

        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let entry = try JSONDecoder().decode(Entry<Value>.self, from: data)

            if entry.isExpired {
                try fileManager.removeItem(at: url)
                return nil
            }

            return entry.value
        } catch {
            try? fileManager.removeItem(at: url)
            return nil
        }
    }

    func insert<Value>(
        _ value: Value,
        forKey key: String,
        expiry: CacheExpiry
    ) async throws where Value: Codable & Sendable {
        let expirationDate = expiry.interval.map {
            Date().addingTimeInterval($0)
        }

        let entry = Entry(value: value, expirationDate: expirationDate)
        let data = try JSONEncoder().encode(entry)

        try data.write(to: fileURL(for: key), options: [.atomic])
    }

    func remove(forKey key: String) async throws {
        let url = fileURL(for: key)

        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }

    func removeAll() async throws {
        if fileManager.fileExists(atPath: directory.path) {
            try fileManager.removeItem(at: directory)
        }

        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: nil
        )
    }
}

// MARK: - HELPER FUNCTIONS -
extension DiskCacheStore {

    private func fileURL(for key: String) -> URL {
        let digest = SHA256.hash(data: Data(key.utf8))
        let filename = digest.map {
            String(format: "%02x", $0)
        }.joined()

        return directory.appendingPathComponent(filename)
    }
}
