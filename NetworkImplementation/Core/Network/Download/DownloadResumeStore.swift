//
//  DownloadResumeStore.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation
import CryptoKit

protocol DownloadResumeStoring: Sendable {
    func save(_ data: Data, identifier: String) async throws
    func load(identifier: String) async throws -> Data?
    func remove(identifier: String) async throws
}

actor DownloadResumeStore: DownloadResumeStoring {

    // MARK: - PROPERTIES -

    /// Private
    private let fileManager: FileManager
    private let directory: URL

    init(fileManager: FileManager = .default) throws {
        self.fileManager = fileManager

        let applicationSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        directory = applicationSupport
            .appendingPathComponent("DownloadResumeData", isDirectory: true)

        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true,
            attributes: [
                .protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
            ]
        )

        var values = URLResourceValues()
        values.isExcludedFromBackup = true

        var directory = directory
        try directory.setResourceValues(values)
    }

    func save(_ data: Data, identifier: String) async throws {
        try data.write(to: fileURL(identifier), options: [
            .atomic,
            .completeFileProtectionUntilFirstUserAuthentication
        ])
    }

    func load(identifier: String) async throws -> Data? {
        let url = fileURL(identifier)

        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }

        return try Data(contentsOf: url)
    }

    func remove(identifier: String) async throws {
        let url = fileURL(identifier)

        guard fileManager.fileExists(atPath: url.path) else {
            return
        }

        try fileManager.removeItem(at: url)
    }
}

// MARK: - HELPER FUNCTIONS -
extension DownloadResumeStore {

    private func fileURL(_ identifier: String) -> URL {
        let safeName = SHA256.hash(data: Data(identifier.utf8))
            .map { String(format: "%02x", $0) }
            .joined()

        return directory.appendingPathComponent(safeName)
    }
}
