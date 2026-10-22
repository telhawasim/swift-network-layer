//
//  AuthAPI.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

enum AuthAPI {

    static func login(_ body: LoginRequestDTO) throws -> APIRequest<LoginResponseDTO> {
        try APIRequest(
            pathComponents: ["auth", "login"],
            method: .post,
            body: body,
            authentication: .none,
            retryBehavior: .never
        )
    }

    static func refresh(
        _ body: RefreshTokenRequestDTO
    ) throws -> APIRequest<RefreshTokenResponseDTO> {
        try APIRequest(
            pathComponents: ["auth", "refresh"],
            method: .post,
            body: body,
            authentication: .none,
            retryBehavior: .never
        )
    }

    static func currentUser() -> APIRequest<UserDTO> {
        APIRequest(
            pathComponents: ["auth", "me"],
            method: .get,
            authentication: .bearerRequired
        )
    }
}
