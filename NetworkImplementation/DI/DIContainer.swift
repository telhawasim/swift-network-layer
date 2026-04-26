//
//  DIContainer.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import Foundation

final class DIContainer {
    
    // MARK: - PROPERTIES -
    
    /// Singleton
    static let shared = DIContainer()
    
    // MARK: - INITIALIZER -
    private init() { }
    
    // MARK: - CORE -
    
    lazy var logger: LoggerProtocol = {
        Logger(category: "App", isEnabled: APIConfiguration.enableNetworkLogging)
    }()
    
    lazy var networkLogger: NetworkLoggerProtocol = {
        NetworkLogger(logger: logger, isVerbose: APIConfiguration.isVerboseLogging)
    }()
    
    lazy var keychainManager: KeychainManagerProtocol = {
        KeychainManager.shared
    }()
    
    lazy var tokenManager: TokenManagerProtocol = {
        TokenManager(keychainManager: keychainManager)
    }()
    
    lazy var sessionManager: SessionManager = {
        SessionManager(
            enableSSLPinning: APIConfiguration.enableSSLPinning,
            pinnedDomains: APIConfiguration.pinnedDomains
        )
    }()
    
    lazy var requestAdapter: RequestAdapterProtocol = {
        DefaultRequest(tokenManager: tokenManager)
    }()
    
    lazy var networkClient: NetworkClientProtocol = {
        NetworkClient(
            session: sessionManager.getSession(),
            requestAdapter: requestAdapter,
            logger: networkLogger
        )
    }()
    
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService(client: networkClient)
    }()
    
    // MARK: - DATA SOURCES -
    
    lazy var authRemoteDataSource: AuthRemoteDataSourceProtocol = {
        AuthRemoteDataSource(networkService: networkService)
    }()
    
    lazy var userRemoteDataSource: UserRemoteDataSourceProtocol = {
        UserRemoteDataSource(networkService: networkService)
    }()
    
    lazy var productRemoteDataSource: ProductRemoteDataSourceProtocol = {
        ProductRemoteDataSource(networkService: networkService)
    }()
    
    lazy var secureStorage: SecureStorage = {
        KeychainSecureStorage(keychainManager: keychainManager)
    }()
    
    // MARK: - REPOSITORIES -
    
    lazy var authRepository: AuthRepositoryProtocol = {
        AuthRepositoryImpl(
            remoteDataSource: authRemoteDataSource,
            secureStorage: secureStorage,
            tokenManager: tokenManager
        )
    }()
    
    lazy var userRepository: UserRepositoryProtocol = {
        UserRepositoryImpl(remoteDataSource: userRemoteDataSource)
    }()
    
    lazy var productRepository: ProductRepositoryProtocol = {
        ProductRepositoryImpl(remoteDataSource: productRemoteDataSource)
    }()
    
    // MARK: - USE CASES -
    
    lazy var loginUseCase: LoginUseCaseProtocol = {
        LoginUseCase(repository: authRepository)
    }()
    
    lazy var refreshTokenUseCase: RefreshTokenUseCaseProtocol = {
        RefreshTokenUseCase(repository: authRepository)
    }()
    
    lazy var getUsersUseCase: GetUsersUseCaseProtocol = {
        GetUsersUseCase(repository: userRepository)
    }()
    
    lazy var getUserUseCase: GetUserUseCaseProtocol = {
        GetUserUseCase(repository: userRepository)
    }()
    
    lazy var getProductsUseCase: GetProductsUseCaseProtocol = {
        GetProductsUseCase(repository: productRepository)
    }()
    
    lazy var searchProductsUseCase: SearchProductsUseCaseProtocol = {
        SearchProductsUseCase(repository: productRepository)
    }()
}
