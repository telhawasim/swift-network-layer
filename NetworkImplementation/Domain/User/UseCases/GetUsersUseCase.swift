import Foundation

protocol GetUsersUseCaseProtocol: Sendable {
    func execute(limit: Int, skip: Int) async throws -> [User]
}

struct GetUsersUseCase: GetUsersUseCaseProtocol {
    private let repository: any UserRepositoryProtocol

    init(repository: any UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(limit: Int, skip: Int) async throws -> [User] {
        guard limit > 0, skip >= 0 else { throw ValidationError.invalidPagination }
        return try await repository.getUsers(limit: limit, skip: skip)
    }
}
