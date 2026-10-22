//
//  TransferProgress.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

struct TransferProgress: Sendable, Equatable {

    // MARK: - PROPERTIES -

    /// Normal
    let completedBytes: Int64
    let expectedBytes: Int64?
    /// Computed
    var fractionCompleted: Double? {
        guard let expectedBytes, expectedBytes > 0 else {
            return nil
        }

        return min(max(Double(completedBytes) / Double(expectedBytes), 0), 1)
    }
}
