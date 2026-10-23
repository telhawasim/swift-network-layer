//
//  RequestDeduplicationPolicy.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

enum RequestDeduplicationPolicy: Sendable {
    case automatic
    case disabled

    func allowsSharing(for method: HTTPMethod) -> Bool {
        switch self {
        case .automatic:
            return method.supportsAutomaticDeduplication

        case .disabled:
            return false
        }
    }
}
