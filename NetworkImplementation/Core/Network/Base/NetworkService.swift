//
//  NetworkService.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Network Service Protocol
protocol NetworkServiceProtocol {
    func execute<T: Decodable>(_ endpoint: Endpoint) async throws -> T
    func execute(_ endpoint: Endpoint) async throws
}

final class NetworkService {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let client: NetworkClientProtocol
    
    // MARK: - INITIALIZER -
    init(client: NetworkClientProtocol) {
        self.client = client
    }
}

// MARK: - NETWORK SERVICE PROTOCOL FUNCTIONS -
extension NetworkService: NetworkServiceProtocol {
    
    /// In order to execute
    /// - Parameter endpoint: `Endpoint` required endpoint
    /// - Returns: `T` dynamic model
    func execute<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        return try await client.request(endpoint, responseType: T.self)
    }
    
    /// In order to execute
    /// - Parameter endpoint: `Endpoint` required endpoint
    func execute(_ endpoint: Endpoint) async throws {
        try await client.request(endpoint)
    }
}
