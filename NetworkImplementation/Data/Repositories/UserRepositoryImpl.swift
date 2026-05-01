//
//  UserRepositoryImpl.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

final class UserRepositoryImpl: UserRepositoryProtocol {
    
    // MARK: - PROPERTIES -
    
    /// Dependencies
    private let remoteDataSource: UserRemoteDataSourceProtocol
    private let localDataSource: UserLocalDataSourceProtocol
    private let mapper: UserMapperProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    // MARK: - INITIALIZER -
    init(
        remoteDataSource: UserRemoteDataSourceProtocol,
        localDataSource: UserLocalDataSourceProtocol = UserLocalDataSource(),
        mapper: UserMapperProtocol = UserMapper(),
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor.shared
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.mapper = mapper
        self.networkMonitor = networkMonitor
    }
    
    func getUsers(limit: Int, skip: Int) async throws -> [User] {
        if networkMonitor.isConnected {
            do {
                let response = try await remoteDataSource.getUsers(limit: limit, skip: skip)
                try? await localDataSource.saveUsers(response, limit: limit, skip: skip)
                return mapper.toDomainArray(response.users)
            } catch {
                if let cached = try? await localDataSource.getUsers(limit: limit, skip: skip) {
                    return mapper.toDomainArray(cached.users)
                }
                throw error
            }
        } else {
            if let cached = try? await localDataSource.getUsers(limit: limit, skip: skip) {
                return mapper.toDomainArray(cached.users)
            }
            throw NetworkError.noInternetConnection
        }
    }
    
    func getUser(id: Int) async throws -> User {
        if networkMonitor.isConnected {
            do {
                let response = try await remoteDataSource.getUser(id: id)
                try? await localDataSource.saveUser(response)
                return mapper.toDomain(response)
            } catch {
                if let cached = try? await localDataSource.getUser(id: id) {
                    return mapper.toDomain(cached)
                }
                throw error
            }
        } else {
            if let cached = try? await localDataSource.getUser(id: id) {
                return mapper.toDomain(cached)
            }
            throw NetworkError.noInternetConnection
        }
    }
    
    func searchUsers(query: String) async throws -> [User] {
        // Search is usually remote-only but we could cache it if desired.
        // For users, let's keep it remote-only or add simple offline check.
        if networkMonitor.isConnected {
            let response = try await remoteDataSource.searchUsers(query: query)
            return mapper.toDomainArray(response.users)
        } else {
            throw NetworkError.noInternetConnection
        }
    }
}
