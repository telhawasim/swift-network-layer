import Foundation

protocol ProductRepositoryProtocol: Sendable {
    func getProducts(limit: Int, skip: Int) async throws -> [Product]
    func getProduct(id: Int) async throws -> Product
    func searchProducts(query: String) async throws -> [Product]
    func getProducts(category: String) async throws -> [Product]
}
