//
//  GetProductsUseCase.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

protocol GetProductsUseCaseProtocol {
    func execute(limit: Int, skip: Int) async throws -> [Product]
}

final class GetProductsUseCase: GetProductsUseCaseProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependency
    private let repository: ProductRepositoryProtocol
    
    // MARK: - INITIALIZER -
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(limit: Int = 30, skip: Int = 0) async throws -> [Product] {
        return try await repository.getProducts(limit: limit, skip: skip)
    }
}
