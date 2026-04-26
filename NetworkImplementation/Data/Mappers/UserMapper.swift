//
//  UserMapper.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

protocol UserMapperProtocol {
    func toDomain(_ dto: UserDTO) -> User
    func toDomainArray(_ dtos: [UserDTO]) -> [User]
}

final class UserMapper: UserMapperProtocol {
    func toDomain(_ dto: UserDTO) -> User {
        return User(
            id: dto.id,
            firstName: dto.firstName,
            lastName: dto.lastName,
            email: dto.email,
            phone: dto.phone,
            username: dto.username,
            age: dto.age,
            gender: dto.gender,
            image: dto.image,
            address: mapAddress(dto.address)
        )
    }
    
    func toDomainArray(_ dtos: [UserDTO]) -> [User] {
        return dtos.map { toDomain($0) }
    }
    
    private func mapAddress(_ dto: AddressDTO?) -> Address? {
        guard let dto = dto else { return nil }
        return Address(
            address: dto.address,
            city: dto.city,
            state: dto.state,
            postalCode: dto.postalCode,
            latitude: dto.coordinates.lat,
            longitude: dto.coordinates.lng
        )
    }
}
