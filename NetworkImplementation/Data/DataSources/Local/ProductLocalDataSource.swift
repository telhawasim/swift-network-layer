//
//  ProductLocalDataSource.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 01/05/2026.
//

import Foundation

protocol ProductLocalDataSourceProtocol {
    func getProducts(limit: Int, skip: Int) async throws -> ProductsResponseDTO?
    func saveProducts(_ response: ProductsResponseDTO, limit: Int, skip: Int) async throws
    
    func getProduct(id: Int) async throws -> ProductDTO?
    func saveProduct(_ product: ProductDTO) async throws
    
    func searchProducts(query: String) async throws -> ProductSearchResponseDTO?
    func saveSearchProducts(_ response: ProductSearchResponseDTO, query: String) async throws
    
    func getProductsByCategory(category: String) async throws -> ProductsResponseDTO?
    func saveProductsByCategory(_ response: ProductsResponseDTO, category: String) async throws
}

final class ProductLocalDataSource: ProductLocalDataSourceProtocol {
    
    private let cacheManager: CacheManagerProtocol
    
    init(cacheManager: CacheManagerProtocol = CacheManager()) {
        self.cacheManager = cacheManager
    }
    
    func getProducts(limit: Int, skip: Int) async throws -> ProductsResponseDTO? {
        return try cacheManager.get(forKey: "products_limit_\(limit)_skip_\(skip)")
    }
    
    func saveProducts(_ response: ProductsResponseDTO, limit: Int, skip: Int) async throws {
        try cacheManager.set(response, forKey: "products_limit_\(limit)_skip_\(skip)", expiry: .hours(1))
    }
    
    func getProduct(id: Int) async throws -> ProductDTO? {
        return try cacheManager.get(forKey: "product_\(id)")
    }
    
    func saveProduct(_ product: ProductDTO) async throws {
        try cacheManager.set(product, forKey: "product_\(product.id)", expiry: .hours(24))
    }
    
    func searchProducts(query: String) async throws -> ProductSearchResponseDTO? {
        return try cacheManager.get(forKey: "search_products_\(query)")
    }
    
    func saveSearchProducts(_ response: ProductSearchResponseDTO, query: String) async throws {
        try cacheManager.set(response, forKey: "search_products_\(query)", expiry: .minutes(30))
    }
    
    func getProductsByCategory(category: String) async throws -> ProductsResponseDTO? {
        return try cacheManager.get(forKey: "products_category_\(category)")
    }
    
    func saveProductsByCategory(_ response: ProductsResponseDTO, category: String) async throws {
        try cacheManager.set(response, forKey: "products_category_\(category)", expiry: .hours(1))
    }
}
