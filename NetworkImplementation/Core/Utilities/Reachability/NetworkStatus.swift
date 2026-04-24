//
//  NetworkStatus.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

/// Enum for network status
public enum NetworkStatus: Sendable, Equatable {
    case connected(ConnectionType)
    case disconnected
    
    /// Enum for connection type
    public enum ConnectionType: Sendable {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    /// Computed Properties
    public var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }
}
