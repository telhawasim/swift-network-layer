//
//  ProductRepositoryImpl.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

final class ProductRepositoryImpl: ProductRepositoryProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let remoteDataSource: ProductRemoteDataSourceProtocol
    private let mapper: ProductMapperProtocol
    
    // MARK: - INITIALIZER -
    init(
        remoteDataSource: ProductRemoteDataSourceProtocol,
        mapper: ProductMapperProtocol = ProductMapper()
    ) {
        self.remoteDataSource = remoteDataSource
        self.mapper = mapper
    }
    
    func getProducts(limit: Int, skip: Int) async throws -> [Product] {
        let response = try await remoteDataSource.getProducts(limit: limit, skip: skip)
        return mapper.ToDomainArray(response.products)
    }
    
    func getProduct(id: Int) async throws -> Product {
        let response = try await remoteDataSource.getProduct(id: id)
        return mapper.toDomain(response)
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        let response = try await remoteDataSource.searchProducts(query: query)
        return mapper.ToDomainArray(response.products)
    }
    
    func getProductsByCategory(category: String) async throws -> [Product] {
        let response = try await remoteDataSource.getProductsByCategory(category: category)
        return mapper.ToDomainArray(response.products)
    }
}
