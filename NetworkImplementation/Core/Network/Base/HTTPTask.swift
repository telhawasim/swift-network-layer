//
//  HTTPTask.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Enum for HTTP Task
enum HTTPTask {
    case request
    case requestParameters(bodyParameters: [String: Any]?, urlParameters: [String: Any]?)
    case requestParametersAndHeaders(
        bodyParameters: [String: Any]?,
        urlParameters: [String: Any]?,
        headers: [String: String]?
    )
}
