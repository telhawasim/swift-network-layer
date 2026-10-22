//
//  SessionFactory.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

enum SessionFactory {

    static func make(timeout: TimeInterval, pinning: PinningConfiguration) -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout * 4
        configuration.waitsForConnectivity = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData

        if pinning.pinsByHost.isEmpty {
            return URLSession(configuration: configuration)
        }

        return URLSession(
            configuration: configuration,
            delegate: CertificatePinningDelegate(configuration: pinning),
            delegateQueue: nil
        )
    }
}
