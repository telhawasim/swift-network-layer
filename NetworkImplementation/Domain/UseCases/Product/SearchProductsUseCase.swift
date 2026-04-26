//
//  SearchProductsUseCase.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

protocol SearchProductsUseCaseProtocol {
    func execute(query: String) async throws -> [Product]
}

final class SearchProductsUseCase: SearchProductsUseCaseProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let repository: ProductRepositoryProtocol
    
    // MARK: - INITIALIZER -
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> [Product] {
        guard !query.isEmpty else {
            throw ValidationError.emptySearchQuery
        }
        
        return try await repository.searchProducts(query: query)
    }
}
