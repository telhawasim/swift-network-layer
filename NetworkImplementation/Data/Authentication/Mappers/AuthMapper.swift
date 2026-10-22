//
//  AuthMapper.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

protocol AuthMapperProtocol: Sendable {
    func toDTO(username: String, password: String) -> LoginRequestDTO
    func toDomain(_ dto: LoginResponseDTO) -> AuthToken
}

struct AuthMapper: AuthMapperProtocol {

    func toDTO(username: String, password: String) -> LoginRequestDTO {
        return LoginRequestDTO(username: username, password: password)
    }

    func toDomain(_ dto: LoginResponseDTO) -> AuthToken {
        return AuthToken(
            accessToken: dto.accessToken,
            refreshToken: dto.refreshToken,
            expiresIn: dto.expiresIn,
            userId: dto.id,
            username: dto.username
        )
    }
}
