//
//  NetworkError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Enum responsible for all types of network error
enum NetworkError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case requestEncoding(String)
    case responseDecoding(String)
    case cancelled
    case offline
    case timedOut
    case transport(code: Int, description: String)
    case tlsFailure
    case authenticationRequired
    case http(statusCode: Int, message: String?, retryAfter: TimeInterval?)
}

struct ErrorResponseDTO: Decodable, Sendable {
    let message: String
}

extension NetworkError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidURL: "The request URL is invalid."
        case .invalidResponse: "The server returned an invalid response."
        case .requestEncoding: "The request could not be encoded."
        case .responseDecoding: "The response could not be decoded."
        case .cancelled: "The request was cancelled."
        case .offline: "No internet connection is available."
        case .timedOut: "The request timed out."
        case .transport(_, let description): description
        case .tlsFailure: "The secure connection could not be verified."
        case .authenticationRequired: "Your session has expired. Please sign in again."
        case .http(let code, let message, _): message ?? "The server returned HTTP \(code)."
        }
    }
}

extension NetworkError {

    var statusCode: Int? {
        guard case .http(let code, _, _) = self else {
            return nil
        }

        return code
    }

    var retryAfter: TimeInterval? {
        guard case .http(_, _, let retryAfter) = self else {
            return nil
        }

        return retryAfter
    }
}
