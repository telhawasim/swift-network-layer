//
//  ReachabilityProtocol.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

/// Protocol for Reachability
public protocol ReachabilityProtocol: Sendable {
    var currentStatus: NetworkStatus { get async }
    
    func startMonitoring() async
    func stopMonitoring() async
}
