//
//  Endpoint.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Endpoint Protocol
protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: [String: String]? { get }
}

/// Extension for Endpoint
extension Endpoint {
    
    /// Computed Properties
    var urlComponents: URLComponents? {
        guard var components = URLComponents(string: baseURL) else { return nil }
        components.path = path
        
        /// Add URL paramters if present
        if case .requestParameters(_, let urlParameters) = task,
           let parameters = urlParameters {
            components.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        if case .requestParametersAndHeaders(_, let urlParameters, _) = task,
           let parameters = urlParameters {
            components.queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
        }
        
        return components
    }
}
