//
//  CacheFallbackPolicy.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

struct CacheFallbackPolicy: Sendable {

    func permitsFallback(for error: Error) -> Bool {
        guard let networkError = error as? NetworkError else {
            return false
        }

        switch networkError {
        case .offline, .timedOut, .transport:
            return true

        case .http(let statusCode, _, _):
            return (500...599).contains(statusCode)

        case .invalidURL, .invalidResponse, .requestEncoding, .responseDecoding, .cancelled, .tlsFailure, .authenticationRequired:
            return false
        }
    }
}
