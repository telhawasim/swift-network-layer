//
//  NetworkService.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private let session: URLSession
    private let requestBuilder: URLRequestBuilder
    private let interceptors: [RequestInterceptor]
    private let plugins: [NetworkPlugin]
    private let logger: NetworkLogger
    private let configuration: NetworkConfiguration
    private let decoder: JSONDecoder
    
    // MARK: - INITIALIZER -
    init(
        configuration: NetworkConfiguration,
        requestBuilder: URLRequestBuildable = URLRequestBuilder(),
        interceptors: [RequestInterceptor] = [],
        plugins: [NetworkPlugin] = [],
        logger: NetworkLogger = NetworkLogger(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.configuration = configuration
        self.requestBuilder = requestBuilder
        self.interceptors = interceptors
        self.plugins = plugins
        self.logger = logger
        self.decoder = decoder
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.defaultTimeout
        sessionConfig.timeoutIntervalForResource = configuration.defaultTimeout * 2
        sessionConfig.waitsForConnectivity = true
        self.session = URLSession(configuration: sessionConfig)
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async throws -> T {
        let data = try await performRequest(endpoint)
        return try decode(T.self, from: data)
    }
    
    func request(_ endpoint: any Endpoint) async throws -> Data {
        try await performRequest(endpoint)
    }
    
    func upload<T: Decodable>(_ endpoint: Endpoint, type: T.Type, progressHandler: ((Double) -> Void)?) async throws -> T {
        let data = try await performRequest(endpoint)
        return try decode(T.self, from: data)
    }
    
    func downlaod(_ endpoint: any Endpoint, to destination: URL, progressHandler: ((Double) -> Void)?) async throws -> URL {
        let urlRequest = try await buildRequest(for: endpoint)
        
        notifyPlugins(.willSend(urlRequest))
        logger.logRequest(urlRequest)
        
        let (tempURL, response) = try await session.download(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        logger.logResponse(httpResponse, data: nil, url: urlRequest.url)
        notifyPlugins(.didReceive(response, nil))
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(
                statusCode: httpResponse.statusCode,
                data: nil
            )
        }
        
        try FileManager.default.moveItem(at: tempURL, to: destination)
        return destination
    }
    
    func stream<T: Decodable>(_ endpoint: Endpoint, type: T.Type) -> AsyncThrowingStream<T, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let urlRequest = try await buildRequest(for: endpoint)
                    notifyPlugins(.willSend(urlRequest))
                    logger.logRequest(urlRequest)
                    
                    let (bytes, response) = try await session.bytes(for: urlRequest)
                    
                    guard let httpResponse = response as? HTTPURLResponse else {
                        continuation.finish(throwing: NetworkError.invalidResponse)
                        return
                    }
                    
                    guard (200...299).contains(httpResponse.statusCode) else {
                        continuation.finish(
                            throwing: NetworkError.httpError(
                                statusCode: httpResponse.statusCode,
                                data: nil
                            )
                        )
                        return
                    }
                    
                    for try await line in bytes.lines {
                        // Handle Server-Sent Events (SSE) format
                        let cleaned = line
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                            .replacingOccurrences(of: "data:", with: "")
                        
                        guard
                            !cleaned.isEmpty,
                            cleaned != "[DONE]",
                            let data = cleaned.data(using: .utf8)
                        else { continue }
                        
                        let decoded = try self.decoder.decode(T.self, from: data)
                        continuation.yield(decoded)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - HELPER FUNCTIONS -
extension NetworkService {
    
    private func performRequest(
        _ endpoint: Endpoint,
        retryCount: Int = 0
    ) async throws -> Data {
        let urlRequest = try await buildRequest(for: endpoint)
        
        notifyPlugins(.willSend(urlRequest))
        logger.logRequest(urlRequest)
        
        do {
            let (data, response) = try await session.data(for: urlRequest)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            logger.logResponse(httpResponse, data: data, url: urlRequest.url)
            notifyPlugins(.didReceive(response, data))
            
            return try await handleResponse(
                httpResponse,
                data: data,
                endpoint: endpoint,
                retryCount: retryCount
            )
        } catch let error as NetworkError {
            notifyPlugins(.didFail(error))
            throw error
        } catch let urlError as URLError {
            let mapped = mapURLError(urlError)
            notifyPlugins(.didFail(mapped))
            throw mapped
        } catch {
            notifyPlugins(.didFail(error))
            throw NetworkError.underlying(error)
        }
    }
    
    private func handleResponse(
        _ response: HTTPURLResponse,
        data: Data,
        endpoint: Endpoint,
        retryCount: Int
    ) async throws -> Data {
        switch response.statusCode {
        case 200...299:
            return data
            
        case 401:
            guard endpoint.requiresAuthentication, retryCount < 1 else {
                throw NetworkError.unauthorized
            }
            let shouldRetry = try await handleTokenRefresh(retryCount: retryCount)
            guard shouldRetry else { throw NetworkError.unauthorized }
            return try await performRequest(endpoint, retryCount: retryCount + 1)
            
        case 403:
            throw NetworkError.forbidden
            
        case 404:
            throw NetworkError.notFound
            
        case 408:
            throw NetworkError.timeout
            
        case 429:
            throw NetworkError.tooManyRequests
            
        case 500...599:
            guard retryCount < configuration.maxRetryCount else {
                throw NetworkError.serverError(statusCode: response.statusCode, data: data)
            }
            try await exponentialBackoff(retryCount: retryCount)
            return try await performRequest(endpoint, retryCount: retryCount + 1)
            
        default:
            throw NetworkError.httpError(statusCode: response.statusCode, data: data)
        }
    }
    
    private func buildRequest(for endpoint: Endpoint) async throws -> URLRequest {
        var urlRequest = try requestBuilder.build(from: endpoint.asNetworkRequest())
        
        // Apply default headers
        for header in configuration.defaultHeaders.allHeaders {
            if urlRequest.value(forHTTPHeaderField: header.name) == nil {
                urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
            }
        }
        
        // Apply interceptors sequentially
        for interceptor in self.interceptors {
            urlRequest = try await interceptor.intecept(urlRequest, endpoint: endpoint)
        }
        
        return urlRequest
    }
    
    private func handleTokenRefresh(retryCount: Int) async throws -> Bool {
        for interceptor in self.interceptors {
            if let retryable = interceptor as? RetryableInterceptor {
                return try await retryable.shouldRetry(
                    error: .unauthorized,
                    retryCount: retryCount
                )
            }
        }
        return false
    }
    
    private func exponentialBackoff(retryCount: Int) async throws {
        let delay = configuration.retryDelay * pow(2.0, Double(retryCount))
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
    }
    
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        do {
            return try decoder.decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            logger.log(.error, message: "Decoding error: \(decodingError)")
            throw NetworkError.decodingError(decodingError)
        }
    }
    
    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return .hostUnreachable
        case .serverCertificateUntrusted, .clientCertificateRejected:
            return .sslError
        default:
            return .underlying(error)
        }
    }
    
    private func notifyPlugins(_ event: NetworkPluginEvent) {
        plugins.forEach { $0.handle(event) }
    }
}
