//
//  BackgroundTransferEvents.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import UIKit

@MainActor
final class BackgroundTransferEvents {

    static let shared = BackgroundTransferEvents()

    private var completionHandlers: [String: () -> Void] = [:]

    private init() { }

    func register(identifier: String, completionHandler: @escaping () -> Void) {
        completionHandlers[identifier] = completionHandler
    }

    func finish(identifier: String) {
        let completionHandler = completionHandlers.removeValue(forKey: identifier)

        completionHandler?()
    }
}

final class ApplicationDelegate: NSObject, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        Task { @MainActor in
            BackgroundTransferEvents.shared
                .register(identifier: identifier, completionHandler: completionHandler)
        }
    }
}
