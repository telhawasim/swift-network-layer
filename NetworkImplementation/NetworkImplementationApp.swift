//
//  NetworkImplementationApp.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import SwiftUI

@main
struct NetworkImplementationApp: App {
    
    // MARK: - INITIALIZER -
    init() {
        setupDependencies()
    }
    
    // MARK: - LIFECYCLE -
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    /// In ordet to setup dependencies
    private func setupDependencies() {
        /// Initialize DIContainer to setup all dependencies
        _ = DIContainer.shared
        
        /// Start Network Monitoring
        NetworkMonitor.shared.startMonitoring()
        
        /// Any additional setup
        configureLogging()
    }
    
    /// In order to configure logging
    private func configureLogging() {
        let logger = DIContainer.shared.logger
        logger.info("Application started")
    }
}
