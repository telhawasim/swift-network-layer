import Foundation
import Observation

@MainActor
@Observable
final class ProductListViewModel {
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    var searchQuery = ""

    private let getProductsUseCase: any GetProductsUseCaseProtocol
    private let searchProductsUseCase: any SearchProductsUseCaseProtocol
    private let appSession: AppSession
    private let logger: any AppLoggerProtocol
    private var currentPage = 0
    private let pageSize = 20
    private var canLoadMore = true

    init(
        getProductsUseCase: any GetProductsUseCaseProtocol,
        searchProductsUseCase: any SearchProductsUseCaseProtocol,
        appSession: AppSession,
        logger: any AppLoggerProtocol
    ) {
        self.getProductsUseCase = getProductsUseCase
        self.searchProductsUseCase = searchProductsUseCase
        self.appSession = appSession
        self.logger = logger
    }

    func loadProducts() async {
        guard !isLoading, canLoadMore, searchQuery.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let newProducts = try await getProductsUseCase.execute(
                limit: pageSize,
                skip: currentPage * pageSize
            )
            products.append(contentsOf: newProducts)
            currentPage += 1
            canLoadMore = newProducts.count == pageSize
            logger.info("Loaded \(newProducts.count) products")
        } catch {
            await handleAuthenticationFailure(error)
            logger.error("Loading products failed")
            errorMessage = error.localizedDescription
        }
    }

    func search() async {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            await refresh()
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            try await Task.sleep(for: .milliseconds(300))
            try Task.checkCancellation()
            products = try await searchProductsUseCase.execute(query: query)
        } catch is CancellationError {
            return
        } catch {
            await handleAuthenticationFailure(error)
            logger.error("Product search failed")
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        currentPage = 0
        canLoadMore = true
        products = []
        if searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            await loadProducts()
        } else {
            await search()
        }
    }

    private func handleAuthenticationFailure(_ error: Error) async {
        guard let networkError = error as? NetworkError,
              case .authenticationRequired = networkError else { return }
        await appSession.logout()
    }
}
