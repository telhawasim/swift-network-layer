import Foundation

protocol ProductRemoteDataSourceProtocol: Sendable {
    func products(limit: Int, skip: Int) async throws -> [ProductDTO]
    func product(id: Int) async throws -> ProductDTO
    func search(query: String) async throws -> [ProductDTO]
    func products(category: String) async throws -> [ProductDTO]
}

struct ProductRemoteDataSource: ProductRemoteDataSourceProtocol {
    private let client: any NetworkClientProtocol

    init(client: any NetworkClientProtocol) {
        self.client = client
    }

    func products(limit: Int, skip: Int) async throws -> [ProductDTO] {
        try await client.send(ProductAPI.products(limit: limit, skip: skip)).value.products
    }

    func product(id: Int) async throws -> ProductDTO {
        try await client.send(ProductAPI.product(id: id)).value
    }

    func search(query: String) async throws -> [ProductDTO] {
        try await client.send(ProductAPI.search(query: query)).value.products
    }

    func products(category: String) async throws -> [ProductDTO] {
        try await client.send(ProductAPI.category(category)).value.products
    }
}
