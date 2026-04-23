//
//  HTTPHeader.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

struct HTTPHeader: Hashable {
    let name: String
    let value: String
    
    /// Authorization Header
    /// - Parameter bearerToken: `String` token which needs to be added in header
    /// - Returns: `HTTPHeader` return header
    static func authorization(bearerToken: String) -> HTTPHeader {
        HTTPHeader(name: "Authorization", value: "Bearer \(bearerToken)")
    }
    
    /// Content type Header
    /// - Parameter value: `ContentType` type which needs to be added in header
    /// - Returns: `HTTPHeader` return header
    static func contentType(_ value: ContentType) -> HTTPHeader {
        HTTPHeader(name: "Content-Type", value: value.rawValue)
    }
    
    /// Accept Header
    /// - Parameter value: `ContentType` type which needs to be added in header
    /// - Returns: `HTTPHeader` return header
    static func accept(_ value: ContentType) -> HTTPHeader {
        HTTPHeader(name: "Accept", value: value.rawValue)
    }
    
    /// Custom Header
    /// - Parameters:
    ///   - name: `String` name of the header
    ///   - value: `String` value against that name
    /// - Returns: `HTTPHeader` return header
    static func custom(name: String, value: String) -> HTTPHeader {
        HTTPHeader(name: name, value: value)
    }
}

struct HTTPHeaders {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private var headers: [HTTPHeader] = []
    
    // Computed Properties
    var dictionary: [String: String] {
        Dictionary(
            headers.map { ($0.name, $0.value) },
            uniquingKeysWith: { _, last in last }
        )
    }
    var allHeaders: [HTTPHeader] { headers }
    
    // MARK: - INITIALIZERS -
    init() { }
    
    init(_ headers: [HTTPHeader]) {
        self.headers = headers
    }
    
    /// In order to add the header
    /// - Parameter header: `HTTPHeader` header which needs to be added
    mutating func add(_ header: HTTPHeader) {
        headers.removeAll { $0.name.lowercased() == header.name.lowercased() }
        headers.append(header)
    }
    
    /// In order to remove the header
    /// - Parameter name: `String` identifier which needs to be removed
    mutating func remove(name: String) {
        headers.removeAll { $0.name.lowercased() == name.lowercased() }
    }
    
    /// In order to get the value of the specific header
    /// - Parameter name: `String` identifier for the header
    /// - Returns: `String?` header value
    func value(for name: String) -> String? {
        headers.first { $0.name.lowercased() == name.lowercased() }?.value
    }
}

/// Enum for Content Type
enum ContentType: String {
    case json              = "application/json"
    case formURLEncoded    = "application/x-www-form-urlencoded"
    case multipartFormData = "multipart/form-data"
    case xml               = "application/xml"
    case plainText         = "text/plain"
}
