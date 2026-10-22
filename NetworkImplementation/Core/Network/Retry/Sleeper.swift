//
//  Sleeper.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

protocol Sleeper: Sendable {
    func sleep(for duration: Duration) async throws
}

struct TaskSleeper: Sleeper {

    func sleep(for duration: Duration) async throws {
        try await Task.sleep(for: duration)
    }
}
