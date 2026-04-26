//
//  LoginViewModel.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import Foundation

@MainActor
@Observable
final class LoginViewModel {
    
    // MARK: - PROPERTIES -
    
    /// Observable Properties
    var username: String = ""
    var password: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isLoggedIn: Bool = false
    
    /// Dependencies
    private let loginUseCase: LoginUseCaseProtocol
    private let logger: LoggerProtocol
    
    // MARK: - INITIALIZER -
    init(
        loginUseCase: LoginUseCaseProtocol = DIContainer.shared.loginUseCase,
        logger: LoggerProtocol = DIContainer.shared.logger
    ) {
        self.loginUseCase = loginUseCase
        self.logger = logger
    }
    
    /// In order to login
    func login() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let authToken = try await loginUseCase.execute(
                username: username,
                password: password
            )
            
            logger.info("Login successful for user: \(authToken.username)")
            isLoggedIn = true
        } catch let error as NetworkError {
            logger.error("Login failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        } catch {
            logger.error("Login failed: \(error.localizedDescription)")
            errorMessage = "An unexpected error occured"
        }
        
        isLoading = false
    }
}
