//
//  MultipartUploadRequest.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

/// Enum responsible for all type of executions
enum TransferExecution: Sendable {
    case foreground
    case background
}

struct MultipartUploadRequest<Response>: Sendable where Response: Decodable & Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let request: APIRequest<Response>
    let form: MultipartForm
    let execution: TransferExecution
    let identifier: String

    // MARK: - INITIALIZER -
    init(
        request: APIRequest<Response>,
        form: MultipartForm,
        execution: TransferExecution = .foreground,
        identifier: String = UUID().uuidString
    ) {
        self.request = request
        self.form = form
        self.execution = execution
        self.identifier = identifier
    }
}
