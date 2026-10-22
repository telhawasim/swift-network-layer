//
//  PinningConfiguration.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

struct PinningConfiguration: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    let pinsByHost: [String: Set<String>]

    // MARK: - INITIALIZER -
    init(enabled: Bool, pinsByHost: [String: Set<String>]) throws {
        guard enabled else {
            self.pinsByHost = [:]
            return
        }

        guard !pinsByHost.isEmpty else {
            throw PinningConfigurationError.enabledWithoutHosts
        }

        for (host, pins) in pinsByHost where pins.isEmpty {
            throw PinningConfigurationError.enabledWithoutPins(host: host)
        }

        for (host, pins) in pinsByHost {
            for pin in pins where Data(base64Encoded: pin)?.count != 32 {
                throw PinningConfigurationError.invalidPin(host: host)
            }
        }

        self.pinsByHost = pinsByHost
    }

    func pins(for host: String) -> Set<String>? {
        pinsByHost[host.lowercased()]
    }
}
