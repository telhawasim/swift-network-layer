//
//  URLRequest+BearerToken.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

extension URLRequest {

    var bearerToken: String? {
        guard let authorization = value(forHTTPHeaderField: "Authorization") else {
            return nil
        }

        let prefix = "Bearer "

        guard authorization.hasPrefix(prefix) else {
            return nil
        }

        return String(authorization.dropFirst(prefix.count))
    }
}
