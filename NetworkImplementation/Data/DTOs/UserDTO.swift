//
//  UserDTO.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct UserDTO: Codable {
    let id: Int
    let firstName: String
    let lastName: String
    let maidenName: String?
    let age: Int
    let gender: String
    let email: String
    let phone: String
    let username: String
    let password: String?
    let birthDate: String
    let image: String
    let bloodGroup: String?
    let height: Double?
    let weight: Double?
    let eyeColor: String?
    let hair: HairDTO?
    let domain: String?
    let ip: String?
    let address: AddressDTO?
    let macAddress: String?
    let university: String?
    let bank: BankDTO?
    let company: CompanyDTO?
    let ein: String?
    let ssn: String?
    let userAgent: String?
}

struct HairDTO: Codable {
    let color: String
    let type: String
}

struct AddressDTO: Codable {
    let address: String
    let city: String
    let coordinates: CoordinatesDTO
    let postalCode: String
    let state: String
}

struct CoordinatesDTO: Codable {
    let lat: Double
    let lng: Double
}

struct BankDTO: Codable {
    let cardExpire: String
    let cardNumber: String
    let cardType: String
    let currency: String
    let iban: String
}

struct CompanyDTO: Codable {
    let address: AddressDTO
    let department: String
    let name: String
    let title: String
}

struct UsersResponseDTO: Decodable {
    let users: [UserDTO]
    let total: Int
    let skip: Int
    let limit: Int
}
