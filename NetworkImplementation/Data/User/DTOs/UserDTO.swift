import Foundation

struct UserDTO: Codable, Sendable {
    struct AddressDTO: Codable, Sendable {
        let address: String
        let city: String
        let state: String
        let postalCode: String
        let country: String?
    }

    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let image: String
    let address: AddressDTO
}

struct UsersResponseDTO: Codable, Sendable {
    let users: [UserDTO]
    let total: Int
    let skip: Int
    let limit: Int
}
