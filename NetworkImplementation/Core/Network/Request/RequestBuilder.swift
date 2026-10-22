//
//  RequestBuilder.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

protocol RequestBuilderProtocol: Sendable {
    func build<Response>(
        _ request: APIRequest<Response>
    ) async throws -> URLRequest where Response: Decodable & Sendable
}

struct RequestBuilder: RequestBuilderProtocol {

    // MARK: - PROPERTIES -

    /// Normal
    private let baseURL: URL
    private let adapter: any RequestAdapterProtocol
    private let defaultHeaders: [String: String]

    // MARK: - INITIALIZER -
    init(baseURL: URL, adapter: any RequestAdapterProtocol, defaultHeaders: [String : String]) {
        self.baseURL = baseURL
        self.adapter = adapter
        self.defaultHeaders = defaultHeaders
    }

    func build<Response>(
        _ request: APIRequest<Response>
    ) async throws -> URLRequest where Response : Decodable & Sendable {
        let endpointURL = request.pathComponents.reduce(baseURL) {
            $0.appendingPathComponent($1)
        }

        guard var components = URLComponents(url: endpointURL, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        if !request.queryItems.isEmpty {
            components.queryItems = request.queryItems.map {
                URLQueryItem(name: $0.name, value: $0.value)
            }
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.httpBody = request.body

        defaultHeaders.merging(request.headers) { _, endpointValue in
            endpointValue
        }
        .forEach {
            urlRequest.setValue($1, forHTTPHeaderField: $0)
        }

        if request.body != nil {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        return try await adapter.adapt(urlRequest, authentication: request.authentication)
    }
}
