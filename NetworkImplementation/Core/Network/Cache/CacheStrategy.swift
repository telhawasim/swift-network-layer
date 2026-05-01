//
//  CacheStrategy.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 01/05/2026.
//

import Foundation

/// Defines the strategy for data retrieval and caching
enum CacheStrategy {
    /// Only fetch from the remote data source. No caching involved.
    case remoteOnly
    
    /// Only fetch from the local data source.
    case localOnly
    
    /// Try fetching from local cache first. If not found or expired, fetch from remote.
    case cacheFirst
    
    /// Always fetch from remote first. If it fails (e.g., offline), fallback to local cache.
    case remoteFirst
    
    /// Fetch from remote and update the cache, but also return the cached data immediately if available (Observed behavior).
    /// This is often implemented with Combine or AsyncSequence, but for simple async/await, we'll focus on the first four.
}
