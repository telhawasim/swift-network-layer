import Foundation

protocol SearchProductsUseCaseProtocol: Sendable {
    func execute(query: String) async throws -> [Product]
}

struct SearchProductsUseCase: SearchProductsUseCaseProtocol {
    private let repository: any ProductRepositoryProtocol

    init(repository: any ProductRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String) async throws -> [Product] {
        let query = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { throw ValidationError.emptySearchQuery }
        return try await repository.searchProducts(query: query)
    }
}
