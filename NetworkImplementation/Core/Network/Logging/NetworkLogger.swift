//
//  NetworkLogger.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Protocol for Network Logger
protocol NetworkLoggerProtocol: Sendable {
    func request(_ request: URLRequest, attempt: Int)
    func response(_ response: HTTPURLResponse, data: Data)
    func failure(_ error: NetworkError)
}

struct NetworkLogger: NetworkLoggerProtocol {

    // MARK: - PROPERTIES -

    /// Normal
    private let logger: any AppLoggerProtocol
    private let redactor: SensitiveDataRedactor
    private let verbose: Bool

    // MARK: - INITIALIZER -
    init(
        logger: any AppLoggerProtocol,
        redactor: SensitiveDataRedactor = SensitiveDataRedactor(),
        verbose: Bool
    ) {
        self.logger = logger
        self.redactor = redactor
        self.verbose = verbose
    }

    func request(_ request: URLRequest, attempt: Int) {
        guard verbose else { return }

        let headers = redactor.headers(request.allHTTPHeaderFields ?? [:])

        logger.debug(
            """
            REQUEST
            attempt: \(attempt)
            method: \(request.httpMethod ?? "UNKNOWN")
            url: \(redactor.url(request.url))
            headers: \(headers)
            body: \(redactor.body(request.httpBody))
            """
        )
    }

    func response(_ response: HTTPURLResponse, data: Data) {
        guard verbose else { return }

        let headers = response.allHeaderFields.reduce(into: [String: String]()) { result, entry in
            result[String(describing: entry.key)] = String(describing: entry.value)
        }

        logger.debug(
            """
            RESPONSE
            status: \(response.statusCode)
            url: \(redactor.url(response.url))
            headers: \(redactor.headers(headers))
            body: \(redactor.body(data))
            """
        )
    }

    func failure(_ error: NetworkError) {
        switch error {
        case .http(let statusCode, _, _):
            logger.error("Network request failed with HTTP \(statusCode)")
        case .transport(let code, _):
            logger.error("Network transport failed with code \(code)")
        default:
            logger.error("Network request failed: \(String(describing: error))")
        }
    }
}
