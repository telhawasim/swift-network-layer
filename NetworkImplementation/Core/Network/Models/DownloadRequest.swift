//
//  DownloadRequest.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

struct DownloadDestination: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let allowedDirectory: URL
    let filename: String
    let overwriteExistingFile: Bool

    // MARK: - INITIALIZER -
    init(allowedDirectory: URL, filename: String, overwriteExistingFile: Bool = false) {
        self.allowedDirectory = allowedDirectory
        self.filename = filename
        self.overwriteExistingFile = overwriteExistingFile
    }
}

struct DownloadValidationPolicy: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let maximumFileSize: Int64?
    let allowedContentTypes: Set<String>
    let expectedSHA256: String?

    // MARK: - INITIALIZER -
    init(
        maximumFileSize: Int64? = nil,
        allowedContentTypes: Set<String> = [],
        expectedSHA256: String? = nil
    ) {
        self.maximumFileSize = maximumFileSize
        self.allowedContentTypes = Set(allowedContentTypes.map { $0.lowercased() })
        self.expectedSHA256 = expectedSHA256?.lowercased()
    }
}

struct DownloadRequest: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let request: APIRequest<EmptyResponse>
    let destination: DownloadDestination
    let validation: DownloadValidationPolicy
    let execution: TransferExecution
    let resumeIdentifier: String

    // MARK: - INITIALIZER -
    init(
        request: APIRequest<EmptyResponse>,
        destination: DownloadDestination,
        validation: DownloadValidationPolicy,
        execution: TransferExecution = .foreground,
        resumeIdentifier: String = UUID().uuidString
    ) {
        self.request = request
        self.destination = destination
        self.validation = validation
        self.execution = execution
        self.resumeIdentifier = resumeIdentifier
    }
}

struct DownloadFile: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let url: URL
    let size: Int64
    let contentType: String?
    let sha256: String
}

struct DownloadResumeToken: Codable, Sendable, Equatable {

    // MARK: - PROPERTIES -

    /// Normal
    let identifier: String
}
