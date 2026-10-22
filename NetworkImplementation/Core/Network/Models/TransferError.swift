//
//  TransferError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

enum TransferError: Error, Sendable {
    case emptyMultipartForm
    case invalidMultipartField(String)
    case temporaryFileCreationFailed
    case invalidHTTPResponse
    case http(statusCode: Int)
    case responseDecoding(String)
    case transport(String)
    case cancelled
    case interrupted(resumeToken: DownloadResumeToken)
    case invalidDestination
    case destinationOutsideAllowedDirectory
    case fileAlreadyExists
    case fileTooLarge(actual: Int64, maximum: Int64)
    case invalidContentType(actual: String?, allowed: Set<String>)
    case checksumMismatch
    case missingDownloadedFile
    case missingResumeData
}

extension TransferError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .emptyMultipartForm:
            "A multipart request must contain at least one part."

        case .invalidMultipartField(let field):
            "The multipart field \(field) contains an invalid value."

        case .temporaryFileCreationFailed:
            "The multipart upload file could not be created."

        case .invalidHTTPResponse:
            "The server returned an invalid response."

        case .http(let statusCode):
            "The server returned HTTP \(statusCode)."

        case .responseDecoding:
            "The upload response could not be decoded."

        case .transport(let description):
            description

        case .cancelled:
            "The transfer was cancelled."

        case .interrupted:
            "The download was interrupted and can be resumed."

        case .invalidDestination:
            "The selected download destination is invalid."

        case .destinationOutsideAllowedDirectory:
            "The download destination is outside the allowed directory."

        case .fileAlreadyExists:
            "A file already exists at the destination."

        case .fileTooLarge:
            "The downloaded file exceeds the allowed size."

        case .invalidContentType:
            "The downloaded file type is not allowed."

        case .checksumMismatch:
            "The downloaded file failed integrity validation."

        case .missingDownloadedFile:
            "The downloaded file could not be found."

        case .missingResumeData:
            "The download can no longer be resumed."
        }
    }
}
