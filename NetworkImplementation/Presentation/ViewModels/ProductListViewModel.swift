//
//  ProductListViewModel.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import Foundation

@MainActor
@Observable
final class ProductListViewModel {
    
    // MARK: - PROPERTIES -
    
    /// Observable Properties
    var products: [Product] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var searchQuery: String = ""
    
    /// Dependencies
    private let getProductsUseCase: GetProductsUseCaseProtocol
    private let searchProductsUseCase: SearchProductsUseCaseProtocol
    private let logger: LoggerProtocol
    
    /// Normal
    private var currentPage = 0
    private let pageSize = 20
    
    // MARK: - INITIALIZER -
    init(
        getProductsUseCase: GetProductsUseCaseProtocol = DIContainer.shared.getProductsUseCase,
        searchProductsUseCase: SearchProductsUseCaseProtocol = DIContainer.shared.searchProductsUseCase,
        logger: LoggerProtocol = DIContainer.shared.logger
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.searchProductsUseCase = searchProductsUseCase
        self.logger = logger
    }
    
    /// In order to load products
    func loadProducts() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let newProducts = try await getProductsUseCase.execute(
                limit: pageSize,
                skip: currentPage * pageSize
            )
            
            products.append(contentsOf: newProducts)
            currentPage += 1
            logger.info("Loaded \(newProducts.count) products")
        } catch let error as NetworkError {
            logger.error("Failed to load products: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Failed to load products: \(error.localizedDescription)")
            errorMessage = "An unexpected error occured"
        }
        
        isLoading = false
    }
    
    /// In order to search products
    func searchProducts() async {
        guard !searchQuery.isEmpty else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        products = []
        
        do {
            let searchResults = try await searchProductsUseCase.execute(query: searchQuery)
            products = searchResults
            logger.info("Found \(searchResults.count) products for query: \(searchQuery)")
        } catch let error as NetworkError {
            logger.error("Search failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Search failed: \(error.localizedDescription)")
            errorMessage = "An unexpected error occured"
        }
    }
    
    /// In order to refresh the states
    func refresh() async {
        currentPage = 0
        products = []
        await loadProducts()
    }
}
