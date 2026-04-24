//
//  NetworkError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

/// Enum for Network error
public enum NetworkError: Error, Sendable, LocalizedError {
    /// Request Errors
    case invalidURL(String)
    case invalidRequest(String)
    case encodingFailed(Error)
    
    /// Response Errors
    case invalidResponse
    case decodingFailed(Error)
    case emptyResponse
    
    /// HTTP Errors
    case httpError(statusCode: Int, data: Data?)
    case unauthorized
    case forbidden
    case notFound
    case serverError(statusCode: Int)
    case tooManyRequests(retryAfter: TimeInterval?)
    
    /// Network Errors
    case noInternetConnection
    case timeout
    case cancelled
    case connectionLost
    
    /// Security Errors
    case certificatePinnedFailed
    case sslHandshakeFailed
    case untrustedCertificate
    
    /// Token Errors
    case tokenFailed
    case tokenRefreshFailed
    case missingToken
    
    /// General
    case unknown(Error)
    case custom(String)
    
    /// Computed Properties
    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url): return "Invalid URL: \(url)"
        case .invalidRequest(let reason): return "Invalid request: \(reason)"
        case .encodingFailed(let error): return "Encoding failed: \(error.localizedDescription)"
        case .invalidResponse: return "Invalid response received"
        case .decodingFailed(let error): return "Decoding failed: \(error.localizedDescription)"
        case .emptyResponse: return "Empty response received"
        case .httpError(let statusCode, _): return "HTTP error with status code: \(statusCode)"
        case .unauthorized: return "Unauthorized access"
        case .forbidden: return "Access forbidden"
        case .notFound: return "Resource not found"
        case .serverError(let statusCode): return "Server error with status code: \(statusCode)"
        case .tooManyRequests(let retryAfter):
            if let retry = retryAfter {
                return "Too many request. Retry after \(retry) seconds"
            }
            return "Too many request"
        case .noInternetConnection: return "No internet connection"
        case .timeout: return "Request time out"
        case .cancelled: return "Request was cancelled"
        case .connectionLost: return "Connection was lost"
        case .certificatePinnedFailed: return "Certificate pinning validation failed"
        case .sslHandshakeFailed: return "SSL handshake failed"
        case .untrustedCertificate: return "Untrusted certificate"
        case .tokenFailed: return "Authentication token has expired"
        case .tokenRefreshFailed: return "Failed to refresh authentication token"
        case .missingToken: return "Authentication token is missing"
        case .unknown(let error): return "Unknwon error: \(error.localizedDescription)"
        case .custom(let message): return message
        }
    }
    
    public var isRetryable: Bool {
        switch self {
        case .timeout, .connectionLost, .serverError:
            return true
        case .tooManyRequests:
            return true
        default:
            return false
        }
    }
    
    public var statusCode: Int? {
        switch self {
        case .httpError(let code, _): return code
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .tooManyRequests: return 429
        case .serverError(let code): return code
        default: return nil
        }
    }
    
    /// Factory from HTTP Status
    /// - Parameters:
    ///   - statusCode: `Int` status code
    ///   - data: `Data?` data
    /// - Returns: `NetworkError` network error type
    public static func from(statusCode: Int, data: Data?) -> NetworkError {
        switch statusCode {
        case 401: return .unauthorized
        case 403: return .forbidden
        case 404: return .notFound
        case 429: return .tooManyRequests(retryAfter: nil)
        case 500...599: return .serverError(statusCode: statusCode)
        default: return .httpError(statusCode: statusCode, data: data)
        }
    }
    
    /// Factory from URLError
    /// - Parameter urlError: `URLError` url error
    /// - Returns: `NetworkError` network error type
    public static func from(urlError: URLError) -> NetworkError {
        switch urlError.code {
        case .notConnectedToInternet: return .noInternetConnection
        case .timedOut: return .timeout
        case .cancelled: return .cancelled
        case .networkConnectionLost: return .connectionLost
        case .serverCertificateUntrusted, .serverCertificateHasUnknownRoot: return .untrustedCertificate
        case .secureConnectionFailed: return .sslHandshakeFailed
        default: return .unknown(urlError)
        }
    }
}

/// Equatable Conformance
extension NetworkError: Equatable {
    
    public static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL(let l), .invalidURL(let r)): return l == r
        case (.unauthorized, .unauthorized): return true
        case (.forbidden, .forbidden): return true
        case (.notFound, .notFound): return true
        case (.noInternetConnection, .noInternetConnection): return true
        case (.timeout, .timeout): return true
        case (.cancelled, .cancelled): return true
        case (.tokenFailed, .tokenFailed): return true
        case (.tokenRefreshFailed, .tokenRefreshFailed): return true
        case (.certificatePinnedFailed, .certificatePinnedFailed): return true
        default: return false
        }
    }
}
