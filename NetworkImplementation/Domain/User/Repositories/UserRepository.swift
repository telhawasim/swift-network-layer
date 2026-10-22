import Foundation

protocol UserRepositoryProtocol: Sendable {
    func getUsers(limit: Int, skip: Int) async throws -> [User]
    func getUser(id: Int) async throws -> User
    func searchUsers(query: String) async throws -> [User]
}
