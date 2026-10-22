import Foundation

struct User: Codable, Identifiable, Sendable, Equatable {
    struct Address: Codable, Sendable, Equatable {
        let street: String
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
    let address: Address

    var fullName: String { "\(firstName) \(lastName)" }
}
