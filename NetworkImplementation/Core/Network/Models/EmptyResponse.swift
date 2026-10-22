//
//  EmptyResponse.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

struct EmptyResponse: Decodable, Sendable {
    init() { }

    init(from decoder: Decoder) throws {
        self.init()
    }
}
