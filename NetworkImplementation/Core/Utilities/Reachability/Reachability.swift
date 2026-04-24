//
//  Reachability.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation
import Network

public actor Reachability {
    
    // MARK: - PROPERTIES -
    
    /// Singleton
    public static let shared = Reachability()
    
    /// Normal
    private let monitor: NWPathMonitor
    private let monitorQueue: DispatchQueue
    private var _currentStatus: NetworkStatus = .disconnected
    private var statusContinuations: [UUID: AsyncStream<NetworkStatus>.Continuation] = [:]
    
    // MARK: - INITIALIZER -
    private init() {
        self.monitor = NWPathMonitor()
        self.monitorQueue = DispatchQueue(label: "com.network.reachability", qos: .utility)
    }
    
    /// In order to get status steam
    /// - Returns: `AsyncStream<NetworkStatus>` will provide us the status
    public func statusSteam() -> AsyncStream<NetworkStatus> {
        AsyncStream { continuation in
            let id = UUID()
            
            self.addContinuation(continuation, id: id)
            continuation.yield(self._currentStatus)
            continuation.onTermination = { _ in
                Task {
                    await self.removeContinuation(id: id)
                }
            }
        }
    }
}

// MARK: - REACHABILITY PROTOCOL FUNCTIONS -
extension Reachability: ReachabilityProtocol {
    
    public var currentStatus: NetworkStatus {
        _currentStatus
    }
    
    public func startMonitoring() async {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            
            Task {
                await self.handlePathUpdate(path)
            }
        }
        monitor.start(queue: monitorQueue)
    }
    
    public func stopMonitoring() async {
        monitor.cancel()
    }
}

// MARK: - HELPER FUNCTIONS -
extension Reachability {
    
    private func handlePathUpdate(_ path: NWPath) {
        let status: NetworkStatus
        
        if path.status == .satisfied {
            let connectionType: NetworkStatus.ConnectionType
            
            if path.usesInterfaceType(.wifi) {
                connectionType = .wifi
            } else if path.usesInterfaceType(.cellular) {
                connectionType = .cellular
            } else if path.usesInterfaceType(.wiredEthernet) {
                connectionType = .ethernet
            } else {
                connectionType = .unknown
            }
            status = .connected(connectionType)
        } else {
            status = .disconnected
        }
        
        _currentStatus = status
        notifyContinuations(status)
    }
    
    /// In order to remove continuation
    /// - Parameter id: `UUID` unique identifier
    private func removeContinuation(id: UUID) {
        statusContinuations.removeValue(forKey: id)
    }
    
    /// In order to notify the continuation
    /// - Parameter status: `NetworkStatus` status of the continuation
    private func notifyContinuations(_ status: NetworkStatus) {
        for continuation in statusContinuations.values {
            continuation.yield(status)
        }
    }
    
    /// In order to add continuation
    /// - Parameters:
    ///   - continuation: `AsyncStream<NetworkStatus>.Continuation` which needs to be added
    ///   - id: `UUID` against unique identifier
    private func addContinuation(
        _ continuation: AsyncStream<NetworkStatus>.Continuation,
        id: UUID
    ) {
        statusContinuations[id] = continuation
    }
}
