//
//  NetworkError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Enum for Network Error
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case encodingError
    case httpError(statusCode: Int, data: Data?)
    case unauthorized
    case forbidden
    case notFound
    case serverError
    case noInternetConnection
    case timeout
    case sslPinnedFailed
    case unknown(Error)
    
    /// Computed Properties
    var localizedDescription: String {
        switch self {
        case .invalidURL:                   "Invalid URL"
        case .noData:                       "No data received"
        case .decodingError(let error):     "Decoding error: \(error.localizedDescription)"
        case .encodingError:                "Encoding error"
        case .httpError(let statusCode, _): "HTTP error with status code: \(statusCode)"
        case .unauthorized:                 "Unauthorized access"
        case .forbidden:                    "Access forbidden"
        case .notFound:                     "Resource not found"
        case .serverError:                  "Server error"
        case .noInternetConnection:         "No internet connection"
        case .timeout:                      "Request timeout"
        case .sslPinnedFailed:              "SSL Pinning validation failed"
        case .unknown(let error):           "Unknown error: \(error.localizedDescription)"
        }
    }
}
