//
//  URLSessionConfiguration+Ext.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

extension URLSessionConfiguration {
    
    static var defaultConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        config.waitsForConnectivity = true
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpAdditionalHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
        return config
    }
    
    static var backgroundConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.background(
            withIdentifier: "com.app.network.background"
        )
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return config
    }
    
    static var ephemeralConfiguration: URLSessionConfiguration {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 30
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        return config
    }
}
