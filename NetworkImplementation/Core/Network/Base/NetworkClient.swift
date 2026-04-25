//
//  NetworkClient.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Network Client Protocol
protocol NetworkClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T
    func request(_ endpoint: Endpoint) async throws
}

final actor NetworkClient {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let session: URLSession
    private let requestAdapter: RequestAdapterProtocol
    private let logger: NetworkLoggerProtocol
    
    // MARK: - INITIALIZER -
    init(
        session: URLSession = .shared,
        requestAdapter: RequestAdapterProtocol,
        logger: NetworkLoggerProtocol = NetworkLogger()
    ) {
        self.session = session
        self.requestAdapter = requestAdapter
        self.logger = logger
    }
}

// MARK: - NETWORK CLIENT PROTOCOL METHODS -
extension NetworkClient: NetworkClientProtocol {
    
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T {
        let request = try await buildRequest(from: endpoint)
        
        logger.logRequest(request)
        
        let (data, response) = try await performRequest(request)
        
        logger.logResponse(response, data: data)
        
        try validateResponse(response, data: data)
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            logger.logError(NetworkError.decodingError(error))
            throw NetworkError.decodingError(error)
        }
    }
    
    func request(_ endpoint: any Endpoint) async throws {
        let request = try await buildRequest(from: endpoint)
        
        logger.logRequest(request)
        
        let (data, response) = try await performRequest(request)
        
        logger.logResponse(response, data: data)
        
        try validateResponse(response, data: data)
    }
}

// MARK: - HELPER FUNCTIONS -
extension NetworkClient {
    
    /// In order to build the request
    /// - Parameter endpoint: `Endpoint` against which request will be built
    /// - Returns: `URLRequest` will return url request
    private func buildRequest(from endpoint: Endpoint) async throws -> URLRequest {
        guard let url = endpoint.urlComponents?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        /// Add endpoint-specific headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        /// Configure body parameters
        switch endpoint.task {
        case .requestParameters(let bodyParameters, _),
                .requestParametersAndHeaders(let bodyParameters, _, _):
            if let bodyParameters = bodyParameters {
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: bodyParameters)
                } catch {
                    throw NetworkError.encodingError
                }
            }
        case .request:
            break
        }
        
        /// Add task-specific headers
        if case .requestParametersAndHeaders(_, _, let headers) = endpoint.task {
            headers?.forEach { key, value in
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        /// Adapt request (add auth tokens, etc.)
        return try await requestAdapter.adapt(request)
    }
    
    /// In order to perform request
    /// - Parameter request: `URLRequest` in order to perform request
    /// - Returns: `(Data, URLResponse)` return data and url response
    private func performRequest(_ request: URLRequest) async throws -> (Data, URLResponse) {
        do {
            return try await session.data(for: request)
        } catch let error as NSError {
            if error.domain == NSURLErrorDomain {
                switch error.code {
                case NSURLErrorNotConnectedToInternet:
                    throw NetworkError.noInternetConnection
                case NSURLErrorTimedOut:
                    throw NetworkError.timeout
                default:
                    throw NetworkError.unknown(error)
                }
            }
            throw NetworkError.unknown(error)
        }
    }
    
    /// In order to validate the response
    /// - Parameters:
    ///   - response: `URLResponse` in order to get status code
    ///   - data: `Data` in order to show error data
    private func validateResponse(_ response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown(NSError(domain: "Invalid response type", code: -1))
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            throw NetworkError.unauthorized
        case 403:
            throw NetworkError.forbidden
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError
        default:
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }
    }
}
