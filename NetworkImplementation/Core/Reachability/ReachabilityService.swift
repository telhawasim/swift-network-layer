//
//  ReachabilityService.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation
import Network

final class ReachabilityService: ReachabilityServiceProtocol {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue
    private(set) var isConnected: Bool = true
    private var continuation: AsyncStream<Bool>.Continuation?
    // Lazy
    lazy var connectionStream: AsyncStream<Bool> = {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
            continuation.yield(self?.isConnected ?? true)
        }
    }()
    
    // MARK: - INITIALIZER -
    init(queue: DispatchQueue = DispatchQueue(label: "com.network.implementation.reachability", qos: .utility)) {
        self.monitor = NWPathMonitor()
        self.queue = queue
    }
    
    // MARK: - DEINITIALIZER -
    deinit { stopMonitoring() }
    
    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            let connected = path.status == .satisfied
            self.isConnected = connected
            self.continuation?.yield(connected)
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(
                    name: connected ? .networkBecameAvailable : .networkBecameUnavailable,
                    object: nil
                )
            }
        }
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
        continuation?.finish()
    }
}
