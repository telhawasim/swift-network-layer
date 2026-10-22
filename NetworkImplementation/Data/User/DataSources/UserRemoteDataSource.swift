import Foundation

protocol UserRemoteDataSourceProtocol: Sendable {
    func users(limit: Int, skip: Int) async throws -> [UserDTO]
    func user(id: Int) async throws -> UserDTO
    func search(query: String) async throws -> [UserDTO]
}

struct UserRemoteDataSource: UserRemoteDataSourceProtocol {
    private let client: any NetworkClientProtocol

    init(client: any NetworkClientProtocol) {
        self.client = client
    }

    func users(limit: Int, skip: Int) async throws -> [UserDTO] {
        try await client.send(UserAPI.users(limit: limit, skip: skip)).value.users
    }

    func user(id: Int) async throws -> UserDTO {
        try await client.send(UserAPI.user(id: id)).value
    }

    func search(query: String) async throws -> [UserDTO] {
        try await client.send(UserAPI.search(query: query)).value.users
    }
}
