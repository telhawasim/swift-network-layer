//
//  EndpointProvider.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

protocol EndpointProvider {
    var configuration: NetworkConfiguration { get }
}

extension EndpointProvider where Self: Endpoint {
    var baseURL: URL {
        guard let url = URL(string: configuration.baseURL) else {
            fatalError("Invalid base URL: \(configuration.baseURL)")
        }
        return url
    }
}
