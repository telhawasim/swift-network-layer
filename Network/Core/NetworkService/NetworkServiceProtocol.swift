//
//  NetworkServiceProtocol.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint, type: T.Type) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
    func upload<T: Decodable>(_ endpoint: Endpoint, type: T.Type, progressHandler: ((Double) -> Void)?) async throws -> T
    func downlaod(_ endpoint: Endpoint, to destination: URL, progressHandler: ((Double) -> Void)?) async throws -> URL
    func stream<T: Decodable>(_ endpoint: Endpoint, type: T.Type) -> AsyncThrowingStream<T, Error>
}
