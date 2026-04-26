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
    
    private var authInterceptor: AuthInterceptorProtocol?
    private var retryInterceptor: RetryInterceptorProtocol?
    
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
    
    /// In order to safely inject interceptors to prevent DI loops
    func setInterceptors(authInterceptor: AuthInterceptorProtocol?, retryInterceptor: RetryInterceptorProtocol?) {
        self.authInterceptor = authInterceptor
        self.retryInterceptor = retryInterceptor
    }
}

// MARK: - NETWORK CLIENT PROTOCOL METHODS -
extension NetworkClient: NetworkClientProtocol {
    
    func request<T: Decodable>(_ endpoint: Endpoint, responseType: T.Type) async throws -> T {
        return try await executeWithRetry(endpoint, attempt: 0, request: nil) { data in
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(error)
            }
        }
    }
    
    func request(_ endpoint: any Endpoint) async throws {
        _ = try await executeWithRetry(endpoint, attempt: 0, request: nil) { _ in return () }
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
    
    /// In order to perform the request loop with retry logic
    /// - Parameters:
    ///   - endpoint: `Endpoint` configuration
    ///   - attempt: `Int` current attempt
    ///   - request: `URLRequest?` optional pre-built request
    ///   - responseMapper: closure to map data to expected type
    private func executeWithRetry<T>(
        _ endpoint: Endpoint,
        attempt: Int,
        request: URLRequest?,
        responseMapper: @escaping (Data) throws -> T
    ) async throws -> T {
        let urlRequest: URLRequest
        if let request = request {
            urlRequest = request
        } else {
            urlRequest = try await buildRequest(from: endpoint)
        }
        
        if attempt == 0 {
            logger.logRequest(urlRequest)
        }
        
        do {
            let (data, response) = try await performRequest(urlRequest)
            
            logger.logResponse(response, data: data)
            try validateResponse(response, data: data)
            
            return try responseMapper(data)
            
        } catch let error as NetworkError {
            logger.logError(error)
            
            /// 1. Handle Authentication Expiry (401)
            if case .unauthorized = error, let authInterceptor = authInterceptor {
                do {
                    let retriedRequest = try await authInterceptor.retry(urlRequest, dueTo: error)
                    return try await executeWithRetry(endpoint, attempt: attempt + 1, request: retriedRequest, responseMapper: responseMapper)
                } catch {
                    throw error
                }
            }
            
            /// 2. Handle Standard Network Retries
            if let retryInterceptor = retryInterceptor, await retryInterceptor.shouldRetry(dueTo: error, attempt: attempt) {
                return try await executeWithRetry(endpoint, attempt: attempt + 1, request: nil, responseMapper: responseMapper)
            }
            
            throw error
            
        } catch {
            logger.logError(error)
            throw error
        }
    }
}
