//
//  QueryItem.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Responsible for carrying the query key and its value
struct QueryItem: Sendable, Equatable {

    // MARK: - PROPERTIES -

    /// Normal
    let name: String
    let value: String

    // MARK: - PROPERTIES -
    init(_ name: String, _ value: String) {
        self.name = name
        self.value = value
    }
}
