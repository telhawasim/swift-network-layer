import Foundation

struct Product: Codable, Identifiable, Sendable, Equatable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let category: String
    let thumbnail: String
    let images: [String]

    var discountedPrice: Double {
        price * (1 - discountPercentage / 100)
    }

    var isInStock: Bool { stock > 0 }
}
