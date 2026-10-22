//
//  DownloadFileValidator.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation
import CryptoKit

actor DownloadFileValidator {

    // MARK: - PROPERTIES -

    /// Private
    private let fileManager: FileManager

    // MARK: - INITIALIZER -
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func validateAndMove(
        stagedFile: URL,
        response: TransferHTTPResponse,
        destination: DownloadDestination,
        policy: DownloadValidationPolicy
    ) throws -> DownloadFile {
        guard stagedFile.isFileURL,
              fileManager.fileExists(atPath: stagedFile.path) else {
            throw TransferError.missingDownloadedFile
        }

        let requestedDirectory = destination.allowedDirectory.standardizedFileURL

        guard requestedDirectory.isFileURL,
              destination.filename == URL(fileURLWithPath: destination.filename).lastPathComponent,
              !destination.filename.isEmpty,
              destination.filename != ".",
              destination.filename != ".." else {
            throw TransferError.invalidDestination
        }

        try fileManager.createDirectory(
            at: requestedDirectory,
            withIntermediateDirectories: true,
            attributes: [
                .protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
            ]
        )

        let directory = requestedDirectory.resolvingSymlinksInPath()

        let finalURL = directory
            .appendingPathComponent(destination.filename)
            .standardizedFileURL

        let directoryPrefix = directory.path.hasSuffix("/") ? directory.path : directory.path + "/"

        guard finalURL.path.hasPrefix(directoryPrefix) else {
            throw TransferError.destinationOutsideAllowedDirectory
        }

        let values = try stagedFile.resourceValues(forKeys: [.fileSizeKey])
        let size = Int64(values.fileSize ?? 0)

        if let maximum = policy.maximumFileSize,
           (size > maximum || response.expectedContentLength > maximum) {
            throw TransferError.fileTooLarge(actual: size, maximum: maximum)
        }

        let contentType = response.mimeType?
            .lowercased()
            .split(separator: ";")
            .first
            .map(String.init)

        if !policy.allowedContentTypes.isEmpty,
           contentType.map(policy.allowedContentTypes.contains) != true {
            throw TransferError
                .invalidContentType(actual: contentType, allowed: policy.allowedContentTypes)
        }

        let checksum = try sha256(of: stagedFile)

        if let expected = policy.expectedSHA256,
           checksum != expected {
            throw TransferError.checksumMismatch
        }

        if fileManager.fileExists(atPath: finalURL.path) {
            guard destination.overwriteExistingFile else {
                throw TransferError.fileAlreadyExists
            }

            _ = try fileManager.replaceItemAt(finalURL, withItemAt: stagedFile)
        } else {
            try fileManager.moveItem(at: stagedFile, to: finalURL)
        }

        return DownloadFile(url: finalURL, size: size, contentType: contentType, sha256: checksum)
    }
}

// MARK: - HELPER FUNCTIONS -
extension DownloadFileValidator {

    private func sha256(of fileURL: URL) throws -> String {
        let handle = try FileHandle(forReadingFrom: fileURL)
        defer { try? handle.close() }

        var hasher = SHA256()

        while true {
            let data = try handle.read(upToCount: 64 * 1_024) ?? Data()

            guard !data.isEmpty else {
                break
            }

            hasher.update(data: data)
        }

        return hasher.finalize()
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
