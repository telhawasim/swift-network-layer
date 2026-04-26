//
//  AuthDTO.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct LoginRequestDTO: Encodable {
    let username: String
    let password: String
}

struct LoginResponseDTO: Decodable {
    let id: Int
    let username: String
    let email: String
    let firstName: String
    let lastName: String
    let gender: String
    let image: String
    let token: String
}

struct RefreshTokenResponseDTO: Decodable {
    let token: String
    let refreshToken: String
}
