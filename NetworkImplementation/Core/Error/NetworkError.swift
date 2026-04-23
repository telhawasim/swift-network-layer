//
//  NetworkError.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

enum NetworkError: Error, Equatable, Hashable {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case noData
    case decodingError(DecodingError)
    case encodingError(Error)
    case httpError(statusCode: Int, data: Data?)
    case serverError(statusCode: Int, data: Data?)
    case unauthorized
    case forbidden
    case notFound
    case timeout
    case noInternetConnection
    case hostUnreachable
    case tooManyRequests
    case cancelled
    case authenticationRequired
    case sslError
    case underlying(Error)
    case custom(message: String, code: Int)
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:               return "The URL is invalid."
        case .invalidRequest:           return "The request is invalid."
        case .invalidResponse:          return "The response is invalid."
        case .noData:                   return "No data received."
        case .decodingError(let e):     return "Decoding error: \(e.localizedDescription)"
        case .encodingError(let e):     return "Encoding error: \(e.localizedDescription)"
        case .httpError(let code, _):   return "HTTP error: \(code)"
        case .serverError(let code, _): return "Server error: \(code)"
        case .unauthorized:             return "Unauthorized. Please log in again."
        case .forbidden:                return "Access forbidden."
        case .notFound:                 return "Resource not found."
        case .timeout:                  return "The request timed out."
        case .noInternetConnection:     return "No internet connection."
        case .hostUnreachable:          return "Host is unreachable."
        case .tooManyRequests:          return "Too many requests. Try again later."
        case .cancelled:                return "Request was cancelled."
        case .authenticationRequired:   return "Authentication required."
        case .sslError:                 return "SSL certificate validation failed."
        case .underlying(let e):        return e.localizedDescription
        case .custom(let msg, _):       return msg
        case .unknown:                  return "An unknown error occurred."
        }
    }
    
    var errorCode: Int {
        switch self {
        case .invalidURL:               return -1001
        case .invalidRequest:           return -1002
        case .invalidResponse:          return -1003
        case .noData:                   return -1004
        case .decodingError:            return -1005
        case .encodingError:            return -1006
        case .httpError(let code, _):   return code
        case .serverError(let code, _): return code
        case .unauthorized:             return 401
        case .forbidden:                return 403
        case .notFound:                 return 404
        case .timeout:                  return 408
        case .noInternetConnection:     return -1009
        case .hostUnreachable:          return -1010
        case .tooManyRequests:          return 429
        case .cancelled:                return -999
        case .authenticationRequired:   return -1011
        case .sslError:                 return -1012
        case .underlying:               return -1013
        case .custom(_, let code):      return code
        case .unknown:                  return -1
        }
    }
    
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.errorCode == rhs.errorCode
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(errorCode)
    }
}
