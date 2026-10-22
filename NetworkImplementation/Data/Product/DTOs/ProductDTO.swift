import Foundation

struct ProductDTO: Codable, Sendable {
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
}

struct ProductsResponseDTO: Codable, Sendable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

typealias ProductSearchResponseDTO = ProductsResponseDTO
