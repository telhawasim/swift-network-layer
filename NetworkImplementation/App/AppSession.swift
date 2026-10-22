import Foundation
import Observation

@MainActor
@Observable
final class AppSession {
    enum State: Equatable {
        case loading
        case signedOut
        case signedIn
    }

    private(set) var state: State = .loading
    private let authSession: any AuthSessionProtocol

    init(authSession: any AuthSessionProtocol) {
        self.authSession = authSession
    }

    func restore() async {
        do {
            state = try await authSession.accessToken() == nil ? .signedOut : .signedIn
        } catch {
            state = .signedOut
        }
    }

    func didLogin() {
        state = .signedIn
    }

    func logout() async {
        await authSession.logout()
        state = .signedOut
    }
}
