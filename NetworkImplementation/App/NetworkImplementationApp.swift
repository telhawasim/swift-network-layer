import SwiftUI

@main
struct NetworkImplementationApp: App {

    /// UIApplicationDelegateAdaptor
    @UIApplicationDelegateAdaptor(ApplicationDelegate.self) private var applicationDelegate

    /// Dependencies
    private let container: AppContainer

    // MARK: - INITIALIZER -
    init() {
        do {
            container = try AppContainer.live()
        } catch {
            fatalError("Application configuration is invalid: \(error)")
        }
    }

    // MARK: - LIFECYCLE -
    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
        }
    }
}
