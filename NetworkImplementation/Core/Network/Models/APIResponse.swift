//
//  APIResponse.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

struct APIResponse<Value: Sendable>: Sendable {
    let value: Value
    let statusCode: Int
    let headers: [String: String]
}
