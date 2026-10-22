import Foundation

protocol UserLocalDataSourceProtocol: Sendable {
    func users(limit: Int, skip: Int) async throws -> [User]?
    func save(users: [User], limit: Int, skip: Int) async throws
    func user(id: Int) async throws -> User?
    func save(user: User) async throws
    func search(query: String) async throws -> [User]?
    func save(searchResults: [User], query: String) async throws
}

struct UserLocalDataSource: UserLocalDataSourceProtocol {
    private let cache: any CacheStore

    init(cache: any CacheStore) {
        self.cache = cache
    }

    func users(limit: Int, skip: Int) async throws -> [User]? {
        try await cache.value(forKey: "users_\(limit)_\(skip)", as: [User].self)
    }

    func save(users: [User], limit: Int, skip: Int) async throws {
        try await cache.insert(users, forKey: "users_\(limit)_\(skip)", expiry: .minutes(15))
    }

    func user(id: Int) async throws -> User? {
        try await cache.value(forKey: "user_\(id)", as: User.self)
    }

    func save(user: User) async throws {
        try await cache.insert(user, forKey: "user_\(user.id)", expiry: .minutes(15))
    }

    func search(query: String) async throws -> [User]? {
        try await cache.value(forKey: "user_search_\(query.lowercased())", as: [User].self)
    }

    func save(searchResults: [User], query: String) async throws {
        try await cache.insert(
            searchResults,
            forKey: "user_search_\(query.lowercased())",
            expiry: .minutes(5)
        )
    }
}
