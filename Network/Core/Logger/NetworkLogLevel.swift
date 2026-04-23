//
//  NetworkLogLevel.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

enum NetworkLogLevel: Int, Comparable {
    case none    = 0
    case error   = 1
    case warning = 2
    case info    = 3
    case debug   = 4
    case verbose = 5
    
    static func < (lhs: NetworkLogLevel, rhs: NetworkLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
