//
//  HTTPMethod.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Enum for all HTTP Method
enum HTTPMethod: String, Sendable {
    case get    = "GET"
    case head   = "HEAD"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"

    var isIdempotent: Bool {
        switch self {
        case .get, .head, .put, .delete:
            return true

        case .post, .patch:
            return false
        }
    }

    var supportsAutomaticDeduplication: Bool {
        switch self {
        case .get, .head:
            return true

        case .post, .put, .patch, .delete:
            return false
        }
    }
}
