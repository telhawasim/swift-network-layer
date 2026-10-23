import Foundation

@MainActor
struct AppContainer {
    let authSession: any AuthSessionProtocol
    let loginUseCase: any LoginUseCaseProtocol
    let getProductsUseCase: any GetProductsUseCaseProtocol
    let searchProductsUseCase: any SearchProductsUseCaseProtocol
    let getUsersUseCase: any GetUsersUseCaseProtocol
    let getUserUseCase: any GetUserUseCaseProtocol
    let logger: any AppLoggerProtocol
    let networkMonitor: NetworkMonitor
    let uploadMediaUseCase: any UploadMediaUseCaseProtocol
    let downloadMediaUseCase: any DownloadMediaUseCaseProtocol

    static func live() throws -> AppContainer {
        let configuration = try APIConfiguration.live()
        let logger = AppLogger(
            subsystem: Bundle.main.bundleIdentifier ?? "NetworkImplementation",
            category: "Application",
            enabled: configuration.loggingEnabled
        )
        let networkLogger = NetworkLogger(
            logger: logger,
            verbose: configuration.verboseLoggingEnabled
        )
        let retryPolicy = ExponentialBackoffRetryPolicy(
            maximumRetryCount: configuration.maximumRetryCount
        )
        let session = SessionFactory.make(
            timeout: configuration.timeout,
            pinning: configuration.pinningConfiguration
        )
        let tokenStore = KeychainTokenStore(keychain: KeychainManager())

        // Refresh requests use an unauthenticated client, avoiding a refresh dependency cycle.
        let refreshBuilder = RequestBuilder(
            baseURL: configuration.baseURL,
            adapter: AuthenticationRequestAdapter(authSession: nil),
            defaultHeaders: ["Accept": "application/json"]
        )
        let refreshClient = NetworkClient(
            session: session,
            requestBuilder: refreshBuilder,
            authSession: nil,
            retryPolicy: retryPolicy,
            fingerprintBuilder: SHA256RequestFingerprintBuilder(),
            inFlightRequestStore: InFlightRequestStore(),
            logger: networkLogger
        )
        let authSession = AuthSession(
            tokenStore: tokenStore,
            tokenRefresher: RefreshTokenService(client: refreshClient)
        )

        let requestBuilder = RequestBuilder(
            baseURL: configuration.baseURL,
            adapter: AuthenticationRequestAdapter(authSession: authSession),
            defaultHeaders: ["Accept": "application/json"]
        )
        let client = NetworkClient(
            session: session,
            requestBuilder: requestBuilder,
            authSession: authSession,
            retryPolicy: retryPolicy,
            fingerprintBuilder: SHA256RequestFingerprintBuilder(),
            inFlightRequestStore: InFlightRequestStore(),
            logger: networkLogger
        )
        let cache = try DiskCacheStore()

        let authRepository = AuthRepositoryImpl(
            remoteDataSource: AuthRemoteDataSource(client: client),
            authSession: authSession
        )
        let productRepository = ProductRepositoryImpl(
            remote: ProductRemoteDataSource(client: client),
            local: ProductLocalDataSource(cache: cache)
        )
        let userRepository = UserRepositoryImpl(
            remote: UserRemoteDataSource(client: client),
            local: UserLocalDataSource(cache: cache)
        )
        let networkMonitor = NetworkMonitor()
        networkMonitor.start()

        let backgroundIdentifier = [
            Bundle.main.bundleIdentifier ?? "NetworkImplementation",
            "file-transfers"
        ].joined(separator: ".")

        let trustEvaluator = ServerTrustEvaluator(configuration: configuration.pinningConfiguration)

        let transferDelegate = TransferSessionDelegate(
            trustEvaluator: trustEvaluator,
            backgroundEventsFinished: {
                Task { @MainActor in
                    BackgroundTransferEvents.shared.finish(identifier: backgroundIdentifier)
                }
            }
        )

        let transferSessions = TransferSession(
            delegate: transferDelegate,
            timeout: configuration.timeout,
            backgroundIdentifier: backgroundIdentifier
        )

        let fileTransferClient = FileTransferClient(
            requestBuilder: requestBuilder,
            sessions: transferSessions,
            delegate: transferDelegate,
            multipartEncoder: MultipartFormEncoder(),
            resumeStore: try DownloadResumeStore(),
            validator: DownloadFileValidator()
        )
        let mediaRepository = MediaRepositoryImpl(
            remote: MediaRemoteDataSource(transferClient: fileTransferClient)
        )

        return AppContainer(
            authSession: authSession,
            loginUseCase: LoginUseCase(repository: authRepository),
            getProductsUseCase: GetProductsUseCase(repository: productRepository),
            searchProductsUseCase: SearchProductsUseCase(repository: productRepository),
            getUsersUseCase: GetUsersUseCase(repository: userRepository),
            getUserUseCase: GetUserUseCase(repository: userRepository),
            logger: logger,
            networkMonitor: networkMonitor,
            uploadMediaUseCase: UploadMediaUseCase(repository: mediaRepository),
            downloadMediaUseCase: DownloadMediaUseCase(repository: mediaRepository)
        )
    }
}
