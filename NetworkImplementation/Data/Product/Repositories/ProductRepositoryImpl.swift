//
//  ProductRepositoryImpl.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 21/10/2026.
//

import Foundation

struct ProductRepositoryImpl: ProductRepositoryProtocol {
    private let remote: any ProductRemoteDataSourceProtocol
    private let local: any ProductLocalDataSourceProtocol
    private let mapper: ProductMapper
    private let fallbackPolicy: CacheFallbackPolicy

    init(
        remote: any ProductRemoteDataSourceProtocol,
        local: any ProductLocalDataSourceProtocol,
        mapper: ProductMapper = ProductMapper(),
        fallbackPolicy: CacheFallbackPolicy = CacheFallbackPolicy()
    ) {
        self.remote = remote
        self.local = local
        self.mapper = mapper
        self.fallbackPolicy = fallbackPolicy
    }

    func getProducts(limit: Int, skip: Int) async throws -> [Product] {
        do {
            let products = try await remote.products(limit: limit, skip: skip).map(mapper.toDomain)
            try? await local.save(products: products, limit: limit, skip: skip)
            return products
        } catch {
            guard fallbackPolicy.permitsFallback(for: error),
                  let cached = try? await local.products(limit: limit, skip: skip) else { throw error }
            return cached
        }
    }

    func getProduct(id: Int) async throws -> Product {
        do {
            let product = mapper.toDomain(try await remote.product(id: id))
            try? await local.save(product: product)
            return product
        } catch {
            guard fallbackPolicy.permitsFallback(for: error),
                  let cached = try? await local.product(id: id) else { throw error }
            return cached
        }
    }

    func searchProducts(query: String) async throws -> [Product] {
        do {
            let products = try await remote.search(query: query).map(mapper.toDomain)
            try? await local.save(searchResults: products, query: query)
            return products
        } catch {
            guard fallbackPolicy.permitsFallback(for: error),
                  let cached = try? await local.search(query: query) else { throw error }
            return cached
        }
    }

    func getProducts(category: String) async throws -> [Product] {
        do {
            let products = try await remote.products(category: category).map(mapper.toDomain)
            try? await local.save(products: products, category: category)
            return products
        } catch {
            guard fallbackPolicy.permitsFallback(for: error),
                  let cached = try? await local.products(category: category) else { throw error }
            return cached
        }
    }
}
