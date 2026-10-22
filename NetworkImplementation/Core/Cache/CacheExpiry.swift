//
//  CacheExpiry.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

enum CacheExpiry: Sendable {
    case never
    case seconds(TimeInterval)
    case minutes(TimeInterval)
    case hours(TimeInterval)
    case days(TimeInterval)

    var interval: TimeInterval? {
        switch self {
        case .never:
            return nil

        case .seconds(let timeInterval):
            return timeInterval

        case .minutes(let timeInterval):
            return timeInterval * 60

        case .hours(let timeInterval):
            return timeInterval * 3_600

        case .days(let timeInterval):
            return timeInterval * 86_400
        }
    }
}
