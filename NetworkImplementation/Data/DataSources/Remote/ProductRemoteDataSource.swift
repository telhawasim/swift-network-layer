//
//  ProductRemoteDataSource.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Product Remote Datasource Protocol
protocol ProductRemoteDataSourceProtocol {
    func getProducts(limit: Int, skip: Int) async throws -> ProductsResponseDTO
    func getProduct(id: Int) async throws -> ProductDTO
    func searchProducts(query: String) async throws -> ProductSearchResponseDTO
    func getProductsByCategory(category: String) async throws -> ProductsResponseDTO
}

final class ProductRemoteDataSource: ProductRemoteDataSourceProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let networkService: NetworkServiceProtocol
    
    // MARK: - INITIALIZER -
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getProducts(limit: Int, skip: Int) async throws -> ProductsResponseDTO {
        let endpoint = ProductEndpoint.getProducts(limit: limit, skip: skip)
        return try await networkService.execute(endpoint)
    }
    
    func getProduct(id: Int) async throws -> ProductDTO {
        let endpoint = ProductEndpoint.getProduct(id: id)
        return try await networkService.execute(endpoint)
    }
    
    func searchProducts(query: String) async throws -> ProductSearchResponseDTO {
        let endpoint = ProductEndpoint.searchProducts(query: query)
        return try await networkService.execute(endpoint)
    }
    
    func getProductsByCategory(category: String) async throws -> ProductsResponseDTO {
        let endpoint = ProductEndpoint.getProductsByCategory(category: category)
        return try await networkService.execute(endpoint)
    }
}
