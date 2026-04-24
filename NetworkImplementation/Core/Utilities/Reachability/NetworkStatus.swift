//
//  NetworkStatus.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

public enum NetworkStatus: Sendable, Equatable {
    case connected(ConnectionType)
    case disconnected
    
    public enum ConnectionType: Sendable {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    public var isConnected: Bool {
        if case .connected = self { return true }
        return false
    }
}
