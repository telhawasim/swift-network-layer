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
    private let localDataSource: ProductLocalDataSourceProtocol
    private let mapper: ProductMapperProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    // MARK: - INITIALIZER -
    init(
        remoteDataSource: ProductRemoteDataSourceProtocol,
        localDataSource: ProductLocalDataSourceProtocol = ProductLocalDataSource(),
        mapper: ProductMapperProtocol = ProductMapper(),
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor.shared
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.mapper = mapper
        self.networkMonitor = networkMonitor
    }
    
    func getProducts(limit: Int, skip: Int) async throws -> [Product] {
        if networkMonitor.isConnected {
            do {
                let response = try await remoteDataSource.getProducts(limit: limit, skip: skip)
                try? await localDataSource.saveProducts(response, limit: limit, skip: skip)
                return mapper.ToDomainArray(response.products)
            } catch {
                // If remote fails, try local fallback
                if let cached = try? await localDataSource.getProducts(limit: limit, skip: skip) {
                    return mapper.ToDomainArray(cached.products)
                }
                throw error
            }
        } else {
            // Offline: use local data
            if let cached = try? await localDataSource.getProducts(limit: limit, skip: skip) {
                return mapper.ToDomainArray(cached.products)
            }
            throw NetworkError.noInternetConnection
        }
    }
    
    func getProduct(id: Int) async throws -> Product {
        if networkMonitor.isConnected {
            do {
                let response = try await remoteDataSource.getProduct(id: id)
                try? await localDataSource.saveProduct(response)
                return mapper.toDomain(response)
            } catch {
                if let cached = try? await localDataSource.getProduct(id: id) {
                    return mapper.toDomain(cached)
                }
                throw error
            }
        } else {
            if let cached = try? await localDataSource.getProduct(id: id) {
                return mapper.toDomain(cached)
            }
            throw NetworkError.noInternetConnection
        }
    }
    
    func searchProducts(query: String) async throws -> [Product] {
        if networkMonitor.isConnected {
            do {
                let response = try await remoteDataSource.searchProducts(query: query)
                try? await localDataSource.saveSearchProducts(response, query: query)
                return mapper.ToDomainArray(response.products)
            } catch {
                if let cached = try? await localDataSource.searchProducts(query: query) {
                    return mapper.ToDomainArray(cached.products)
                }
                throw error
            }
        } else {
            if let cached = try? await localDataSource.searchProducts(query: query) {
                return mapper.ToDomainArray(cached.products)
            }
            throw NetworkError.noInternetConnection
        }
    }
    
    func getProductsByCategory(category: String) async throws -> [Product] {
        if networkMonitor.isConnected {
            do {
                let response = try await remoteDataSource.getProductsByCategory(category: category)
                try? await localDataSource.saveProductsByCategory(response, category: category)
                return mapper.ToDomainArray(response.products)
            } catch {
                if let cached = try? await localDataSource.getProductsByCategory(category: category) {
                    return mapper.ToDomainArray(cached.products)
                }
                throw error
            }
        } else {
            if let cached = try? await localDataSource.getProductsByCategory(category: category) {
                return mapper.ToDomainArray(cached.products)
            }
            throw NetworkError.noInternetConnection
        }
    }
}
