//
//  Environment.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 26/04/2026.
//

import Foundation

enum Environment: String {
    case development = "Development"
    case production = "Production"
    
    var displayName: String {
        return rawValue
    }
    
    var isProduction: Bool {
        return self == .production
    }
    
    var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
