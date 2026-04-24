//
//  CertificatePinnerProtocol.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

public protocol CertificatePinnerProtocol: Sendable {
    func validate(_ challenge: URLAuthenticationChallenge) async -> Bool
}
