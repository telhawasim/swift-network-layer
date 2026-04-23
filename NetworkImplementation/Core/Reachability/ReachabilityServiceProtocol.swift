//
//  ReachabilityServiceProtocol.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

protocol ReachabilityServiceProtocol: AnyObject {
    var isConnected: Bool { get }
    func startMonitoring()
    func stopMonitoring()
    
    // AsyncStream for connectivity changes
    var connectionStream: AsyncStream<Bool> { get }
}
