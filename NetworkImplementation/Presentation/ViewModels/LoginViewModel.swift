import Foundation
import Observation

@MainActor
@Observable
final class LoginViewModel {
    var username = ""
    var password = ""
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let loginUseCase: any LoginUseCaseProtocol
    private let appSession: AppSession
    private let logger: any AppLoggerProtocol

    init(
        loginUseCase: any LoginUseCaseProtocol,
        appSession: AppSession,
        logger: any AppLoggerProtocol
    ) {
        self.loginUseCase = loginUseCase
        self.appSession = appSession
        self.logger = logger
    }

    func login() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            _ = try await loginUseCase.execute(username: username, password: password)
            password = ""
            appSession.didLogin()
            logger.info("Login succeeded")
        } catch {
            logger.error("Login failed")
            errorMessage = error.localizedDescription
        }
    }
}
