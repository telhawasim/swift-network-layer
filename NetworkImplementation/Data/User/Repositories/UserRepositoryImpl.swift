import Foundation

struct UserRepositoryImpl: UserRepositoryProtocol {
    private let remote: any UserRemoteDataSourceProtocol
    private let local: any UserLocalDataSourceProtocol
    private let mapper: UserMapper
    private let fallbackPolicy: CacheFallbackPolicy

    init(
        remote: any UserRemoteDataSourceProtocol,
        local: any UserLocalDataSourceProtocol,
        mapper: UserMapper = UserMapper(),
        fallbackPolicy: CacheFallbackPolicy = CacheFallbackPolicy()
    ) {
        self.remote = remote
        self.local = local
        self.mapper = mapper
        self.fallbackPolicy = fallbackPolicy
    }

    func getUsers(limit: Int, skip: Int) async throws -> [User] {
        do {
            let users = try await remote.users(limit: limit, skip: skip).map(mapper.toDomain)
            try? await local.save(users: users, limit: limit, skip: skip)
            return users
        } catch {
            guard fallbackPolicy.permitsFallback(for: error),
                  let cached = try? await local.users(limit: limit, skip: skip) else { throw error }
            return cached
        }
    }

    func getUser(id: Int) async throws -> User {
        do {
            let user = mapper.toDomain(try await remote.user(id: id))
            try? await local.save(user: user)
            return user
        } catch {
            guard fallbackPolicy.permitsFallback(for: error),
                  let cached = try? await local.user(id: id) else { throw error }
            return cached
        }
    }

    func searchUsers(query: String) async throws -> [User] {
        do {
            let users = try await remote.search(query: query).map(mapper.toDomain)
            try? await local.save(searchResults: users, query: query)
            return users
        } catch {
            guard fallbackPolicy.permitsFallback(for: error),
                  let cached = try? await local.search(query: query) else { throw error }
            return cached
        }
    }
}
