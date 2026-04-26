//
//  AuthMapper.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

protocol AuthMapperProtocol {
    func toDTO(username: String, password: String) -> LoginRequestDTO
    func toDomain(_ dto: LoginResponseDTO) -> AuthToken
}

final class AuthMapper: AuthMapperProtocol {
    
    func toDTO(username: String, password: String) -> LoginRequestDTO {
        return LoginRequestDTO(username: username, password: password)
    }
    
    func toDomain(_ dto: LoginResponseDTO) -> AuthToken {
        return AuthToken(
            accessToken: dto.token,
            refreshToken: "",
            expiresIn: 3600,
            userId: dto.id,
            username: dto.username
        )
    }
}
