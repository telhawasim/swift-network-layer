//
//  APIRequest.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Enum for all the retry request behavior
enum RequestRetryBehavior: Sendable {
    case never
    case idempotentOnly
    case always

    /// In order to handle allow retry
    /// - Parameter method: `HTTPMethod` respected http method
    /// - Returns: `Bool` will return `true` is case retry is allowed, otherwise `false`
    func allowsRetry(for method: HTTPMethod) -> Bool {
        switch self {
        case .never:
            return false

        case .idempotentOnly:
            return method.isIdempotent

        case .always:
            return true
        }
    }
}

struct APIRequest<Response: Decodable & Sendable>: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let pathComponents: [String]
    let method: HTTPMethod
    let queryItems: [QueryItem]
    let headers: [String: String]
    let body: Data?
    let authentication: AuthenticationRequirement
    let retryBehavior: RequestRetryBehavior

    // MARK: - INITIALIZER -
    init(
        pathComponents: [String],
        method: HTTPMethod,
        queryItems: [QueryItem] = [],
        headers: [String : String] = [:],
        authentication: AuthenticationRequirement = .bearerRequired,
        retryBehavior: RequestRetryBehavior = .idempotentOnly
    ) {
        self.pathComponents = pathComponents
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = nil
        self.authentication = authentication
        self.retryBehavior = retryBehavior
    }

    init<Body: Encodable>(
        pathComponents: [String],
        method: HTTPMethod,
        queryItems: [QueryItem] = [],
        headers: [String: String] = [:],
        body: Body,
        authentication: AuthenticationRequirement = .bearerRequired,
        retryBehavior: RequestRetryBehavior = .idempotentOnly,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        self.pathComponents = pathComponents
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = try encoder.encode(body)
        self.authentication = authentication
        self.retryBehavior = retryBehavior
    }
}
