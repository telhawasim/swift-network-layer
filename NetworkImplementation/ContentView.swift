import SwiftUI

struct ContentView: View {
    @State private var appSession: AppSession
    @State private var loginViewModel: LoginViewModel
    @State private var productViewModel: ProductListViewModel
    private let networkMonitor: NetworkMonitor

    @MainActor
    init(container: AppContainer) {
        let appSession = AppSession(authSession: container.authSession)
        _appSession = State(initialValue: appSession)
        _loginViewModel = State(initialValue: LoginViewModel(
            loginUseCase: container.loginUseCase,
            appSession: appSession,
            logger: container.logger
        ))
        _productViewModel = State(initialValue: ProductListViewModel(
            getProductsUseCase: container.getProductsUseCase,
            searchProductsUseCase: container.searchProductsUseCase,
            appSession: appSession,
            logger: container.logger
        ))
        networkMonitor = container.networkMonitor
    }

    var body: some View {
        NavigationStack {
            Group {
                switch appSession.state {
                case .loading:
                    ProgressView("Restoring session…")
                case .signedOut:
                    LoginView(viewModel: loginViewModel)
                case .signedIn:
                    ProductListView(viewModel: productViewModel) {
                        await appSession.logout()
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                if !networkMonitor.isConnected {
                    Text("Offline — showing saved data when available")
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(6)
                        .background(.orange)
                }
            }
        }
        .task { await appSession.restore() }
    }
}
