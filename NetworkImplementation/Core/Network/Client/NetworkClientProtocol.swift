//
//  NetworkClientProtocol.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

protocol NetworkClientProtocol: Sendable {
    func send<Response>(
        _ request: APIRequest<Response>
    ) async throws -> APIResponse<Response> where Response: Decodable & Sendable
}
