//
//  ConnectivityPlugin.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

final class ConnectivityPlugin: NetworkPlugin {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private let reachabilityService: ReachabilityServiceProtocol
    
    // MARK: - INITIALIZER -
    init(reachabilityService: ReachabilityServiceProtocol) {
        self.reachabilityService = reachabilityService
    }
    
    func handle(_ event: NetworkPluginEvent) {
        if case .willSend = event, !reachabilityService.isConnected {
            NotificationCenter.default.post(
                name: .networkBecameUnavailable,
                object: nil
            )
        }
    }
}

extension Notification.Name {
    static let networkBecameUnavailable = Notification.Name("networkBecameUnavailable")
    static let networkBecameAvailable   = Notification.Name("networkBecameAvailable")
    static let userSessionExpired       = Notification.Name("userSessionExpired")
}
