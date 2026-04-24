//
//  PinnerMode.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

public enum PinnerMode: Sendable {
    case certificate(Set<String>) // Base64 DER-encoded certificates
    case publicKey(Set<String>)   // Base64 subjectPublicKeyInfo hashes
    case disabled
}
