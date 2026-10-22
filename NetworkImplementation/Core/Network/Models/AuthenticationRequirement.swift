//
//  AuthenticationRequirement.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Enum responsible for all the state of authentication requirements
enum AuthenticationRequirement: Sendable {
    case none
    case bearerIfAvailable
    case bearerRequired

    // MARK: - PROPERTIES -

    /// Computed
    var usesBearerToken: Bool {
        self != .none
    }
}
