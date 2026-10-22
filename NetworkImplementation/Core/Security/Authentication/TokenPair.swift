//
//  TokenPair.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

/// Responsible for holding Session values
struct TokenPair: Codable, Sendable, Equatable {
    let accessToken: String
    let refreshToken: String
}
