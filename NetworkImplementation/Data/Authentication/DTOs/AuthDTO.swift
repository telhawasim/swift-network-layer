//
//  AuthDTO.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

struct LoginRequestDTO: Encodable, Sendable {
    let username: String
    let password: String
}

struct LoginResponseDTO: Decodable, Sendable {
    let id: Int
    let username: String
    let accessToken: String
    let refreshToken: String
    let expiresIn: TimeInterval?

    private enum CodingKeys: String, CodingKey {
        case id
        case username
        case token
        case accessToken
        case refreshToken
        case expiresIn
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        accessToken = try container
            .decodeIfPresent(String.self, forKey: .accessToken) ?? container
            .decode(String.self, forKey: .token)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        expiresIn = try container.decodeIfPresent(TimeInterval.self, forKey: .expiresIn)
    }
}

struct RefreshTokenRequestDTO: Encodable, Sendable {
    let refreshToken: String
}

struct RefreshTokenResponseDTO: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String

    private enum CodingKeys: String, CodingKey {
        case token
        case accessToken
        case refreshToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        accessToken = try container
            .decodeIfPresent(String.self, forKey: .accessToken) ?? container
            .decode(String.self, forKey: .token)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
    }
}
