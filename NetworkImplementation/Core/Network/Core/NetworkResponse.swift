//
//  NetworkResponse.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

/// Network Response
public struct NetworkResponse<T: Sendable>: Sendable {
    public let data: T
    public let statusCode: Int
    public let headers: [AnyHashable: Any]
    public let requestDuration: TimeInterval
    
    // MARK: - INITIALIZER -
    public init(
        data: T,
        statusCode: Int,
        headers: [AnyHashable: Any],
        requestDuration: TimeInterval
    ) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.requestDuration = requestDuration
    }
}

/// Raw Network Response
public struct RawNetworkResponse: Sendable {
    public let data: Data
    public let response: HTTPURLResponse
    public let requestDuration: TimeInterval
    
    /// Computed Properties
    public var statusCode: Int { response.statusCode }
    public var headers: [AnyHashable: Any] { response.allHeaderFields }
    
    // MARK: - INITIALIZER -
    public init(data: Data, response: HTTPURLResponse, requestDuration: TimeInterval) {
        self.data = data
        self.response = response
        self.requestDuration = requestDuration
    }
}

/// API Response
public struct APIResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let success: Bool
    public let data: T?
    public let message: String?
    public let errorCode: String?
    public let timestamp: Date?
    
    enum CodingKeys: String, CodingKey {
        case success
        case data
        case message
        case errorCode = "error_code"
        case timestamp
    }
}

/// Pagination Response
public struct PaginationResponse<T: Decodable & Sendable>: Decodable, Sendable {
    public let items: [T]
    public let totalCount: Int
    public let page: Int
    public let pageSize: Int
    public let hasNextPage: Bool
    
    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
        case page
        case pageSize = "page_size"
        case hasNextPage = "has_next_page"
    }
}

/// Empty Response
public struct EmptyResponse: Decodable, Sendable {
    public init() { }
}
