//
//  NetworkRequest.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

struct NetworkRequest {
    let url: URL
    let method: HTTPMethod
    let task: HTTPTask
    let headers: HTTPHeaders
    let timeout: TimeInterval
    let cachePolicy: CachePolicy
    
    // MARK: - INITIALIZER -
    init(
        url: URL,
        method: HTTPMethod = .get,
        task: HTTPTask = .requestPlain,
        headers: HTTPHeaders = HTTPHeaders(),
        timeout: TimeInterval = 30,
        cachePolicy: CachePolicy = .networkOnly
    ) {
        self.url = url
        self.method = method
        self.task = task
        self.headers = headers
        self.timeout = timeout
        self.cachePolicy = cachePolicy
    }
}
