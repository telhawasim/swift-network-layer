import Foundation

protocol GetUserUseCaseProtocol: Sendable {
    func execute(id: Int) async throws -> User
}

struct GetUserUseCase: GetUserUseCaseProtocol {
    private let repository: any UserRepositoryProtocol

    init(repository: any UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: Int) async throws -> User {
        guard id > 0 else { throw ValidationError.invalidUserId }
        return try await repository.getUser(id: id)
    }
}
