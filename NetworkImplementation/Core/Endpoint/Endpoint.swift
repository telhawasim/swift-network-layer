//
//  Endpoint.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders { get }
    var timeout: TimeInterval { get }
    var cachePolicy: CachePolicy { get }
    var requiresAuthentication: Bool { get }
}

extension Endpoint {
    var timeout: TimeInterval { 30.0 }
    var cachePolicy: CachePolicy { .networkOnly }
    var requiresAuthentication: Bool { true }
    
    var headers: HTTPHeaders {
        var h = HTTPHeaders()
        h.add(.contentType(.json))
        h.add(.accept(.json))
        return h
    }
    
    var url: URL {
        baseURL.appendingPathComponent(path)
    }
    
    func asNetworkRequest() -> NetworkRequest {
        NetworkRequest(
            url: url,
            method: method,
            task: task,
            headers: headers,
            timeout: timeout,
            cachePolicy: cachePolicy
        )
    }
}
