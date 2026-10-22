import Foundation

protocol GetProductsUseCaseProtocol: Sendable {
    func execute(limit: Int, skip: Int) async throws -> [Product]
}

struct GetProductsUseCase: GetProductsUseCaseProtocol {
    private let repository: any ProductRepositoryProtocol

    init(repository: any ProductRepositoryProtocol) {
        self.repository = repository
    }

    func execute(limit: Int, skip: Int) async throws -> [Product] {
        guard limit > 0, skip >= 0 else { throw ValidationError.invalidPagination }
        return try await repository.getProducts(limit: limit, skip: skip)
    }
}
