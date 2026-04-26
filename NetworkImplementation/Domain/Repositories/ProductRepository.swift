//
//  ProductRepository.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

/// Product Repository Protocol
protocol ProductRepositoryProtocol {
    func getProducts(limit: Int, skip: Int) async throws -> [Product]
    func getProduct(id: Int) async throws -> Product
    func searchProducts(query: String) async throws -> [Product]
    func getProductsByCategory(category: String) async throws -> [Product]
}
