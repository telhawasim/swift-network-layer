//
//  AuthToken.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct AuthToken: Sendable, Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval?
    let userId: Int
    let username: String
}
