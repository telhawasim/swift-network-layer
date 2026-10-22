//
//  RequestAdapter.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Request Adapter Protocol
protocol RequestAdapterProtocol: Sendable {
    func adapt(
        _ request: URLRequest,
        authentication: AuthenticationRequirement
    ) async throws -> URLRequest
}

struct AuthenticationRequestAdapter: RequestAdapterProtocol {

    // MARK: - PROPERTIES -

    /// Dependencies
    private let authSession: (any AuthSessionProtocol)?

    // MARK: - INITIALIZER -
    init(authSession: (any AuthSessionProtocol)?) {
        self.authSession = authSession
    }

    func adapt(
        _ request: URLRequest,
        authentication: AuthenticationRequirement
    ) async throws -> URLRequest {
        var adaptedRequest = request

        switch authentication {
        case .none:
            return adaptedRequest

        case .bearerIfAvailable:
            if let token = try await authSession?.accessToken() {
                adaptedRequest.setValue(
                    "Bearer \(token)",
                    forHTTPHeaderField: "Authorization"
                )
            }

        case .bearerRequired:
            guard let token = try await authSession?.accessToken() else {
                throw NetworkError.authenticationRequired
            }

            adaptedRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return adaptedRequest
    }
}
