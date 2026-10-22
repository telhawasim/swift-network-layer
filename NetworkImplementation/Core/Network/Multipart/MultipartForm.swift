//
//  MultipartForm.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

struct MultipartForm: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let parts: [MultipartPart]

    // MARK: - INITIALIZER -
    init(parts: [MultipartPart]) {
        self.parts = parts
    }
}

/// Enum responsible for all type of content for multipart
enum MultipartPart: Sendable {
    case text(name: String, value: String)
    case file(name: String, filename: String, contentType: String, fileURL: URL)
}
