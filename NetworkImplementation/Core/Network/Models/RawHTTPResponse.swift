//
//  RawHTTPResponse.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

struct RawHTTPResponse: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let data: Data
    let statusCode: Int
    let headers: [String: String]

    // MARK: - INITIALIZER -
    init(data: Data, statusCode: Int, headers: [String : String]) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
    }

    init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.statusCode = response.statusCode
        self.headers = response.allHeaderFields.reduce(into: [:]) { result, entry in
            result[String(describing: entry.key)] = String(describing: entry.value)
        }
    }

    func headerValue(for name: String) -> String? {
        headers.first { header in
            header.key.caseInsensitiveCompare(name) == .orderedSame
        }?.value
    }
}
