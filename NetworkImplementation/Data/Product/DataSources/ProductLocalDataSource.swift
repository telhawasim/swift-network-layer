import Foundation

protocol ProductLocalDataSourceProtocol: Sendable {
    func products(limit: Int, skip: Int) async throws -> [Product]?
    func save(products: [Product], limit: Int, skip: Int) async throws
    func product(id: Int) async throws -> Product?
    func save(product: Product) async throws
    func search(query: String) async throws -> [Product]?
    func save(searchResults: [Product], query: String) async throws
    func products(category: String) async throws -> [Product]?
    func save(products: [Product], category: String) async throws
}

struct ProductLocalDataSource: ProductLocalDataSourceProtocol {
    private let cache: any CacheStore

    init(cache: any CacheStore) {
        self.cache = cache
    }

    func products(limit: Int, skip: Int) async throws -> [Product]? {
        try await cache.value(forKey: "products_\(limit)_\(skip)", as: [Product].self)
    }

    func save(products: [Product], limit: Int, skip: Int) async throws {
        try await cache.insert(products, forKey: "products_\(limit)_\(skip)", expiry: .minutes(15))
    }

    func product(id: Int) async throws -> Product? {
        try await cache.value(forKey: "product_\(id)", as: Product.self)
    }

    func save(product: Product) async throws {
        try await cache.insert(product, forKey: "product_\(product.id)", expiry: .minutes(15))
    }

    func search(query: String) async throws -> [Product]? {
        try await cache.value(forKey: "product_search_\(query.lowercased())", as: [Product].self)
    }

    func save(searchResults: [Product], query: String) async throws {
        try await cache.insert(
            searchResults,
            forKey: "product_search_\(query.lowercased())",
            expiry: .minutes(5)
        )
    }

    func products(category: String) async throws -> [Product]? {
        try await cache.value(
            forKey: "product_category_\(category.lowercased())",
            as: [Product].self
        )
    }

    func save(products: [Product], category: String) async throws {
        try await cache.insert(
            products,
            forKey: "product_category_\(category.lowercased())",
            expiry: .minutes(15)
        )
    }
}
