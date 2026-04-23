//
//  CachePlugin.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

final class CachePlugin: NetworkPlugin {
    
    // MARK: - PROPERTIES -
    
    // Normal
    private let cacheService: NetworkCacheServiceProtocol
    
    // MARK: - INITIALIZER -
    init(cacheService: NetworkCacheServiceProtocol) {
        self.cacheService = cacheService
    }
    
    func handle(_ event: NetworkPluginEvent) {
        guard case .didReceive(let response, let data) = event,
              let httpResponse = response as? HTTPURLResponse,
              let data,
              let url = httpResponse.url,
              (200...299).contains(httpResponse.statusCode)
        else { return }
        
        cacheService.save(data, for: url.absoluteString)
    }
}
