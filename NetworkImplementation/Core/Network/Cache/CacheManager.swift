//
//  CacheManager.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 01/05/2026.
//

import Foundation

protocol CacheManagerProtocol {
    func set<T: Codable>(_ object: T, forKey key: String, expiry: CacheExpiry) throws
    func get<T: Codable>(forKey key: String) throws -> T?
    func remove(forKey key: String) throws
    func clearAll() throws
}

enum CacheExpiry {
    case never
    case seconds(TimeInterval)
    case minutes(TimeInterval)
    case hours(TimeInterval)
    case days(TimeInterval)
    
    var timeInterval: TimeInterval {
        switch self {
        case .never: return .infinity
        case .seconds(let v): return v
        case .minutes(let v): return v * 60
        case .hours(let v): return v * 3600
        case .days(let v): return v * 86400
        }
    }
}

private struct CacheEntry<T: Codable>: Codable {
    let object: T
    let expiryDate: Date?
    
    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return Date() > expiryDate
    }
}

final class CacheManager: CacheManagerProtocol {
    
    private let fileManager: FileManager
    private let cacheDirectory: URL
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        self.cacheDirectory = paths[0].appendingPathComponent("NetworkCache")
        
        createCacheDirectoryIfNeeded()
    }
    
    private func createCacheDirectoryIfNeeded() {
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    private func fileURL(for key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? key)
    }
    
    func set<T: Codable>(_ object: T, forKey key: String, expiry: CacheExpiry) throws {
        let expiryDate: Date? = expiry.timeInterval == .infinity ? nil : Date().addingTimeInterval(expiry.timeInterval)
        let entry = CacheEntry(object: object, expiryDate: expiryDate)
        
        let data = try JSONEncoder().encode(entry)
        try data.write(to: fileURL(for: key))
    }
    
    func get<T: Codable>(forKey key: String) throws -> T? {
        let url = fileURL(for: key)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        
        let data = try Data(contentsOf: url)
        let entry = try JSONDecoder().decode(CacheEntry<T>.self, from: data)
        
        if entry.isExpired {
            try remove(forKey: key)
            return nil
        }
        
        return entry.object
    }
    
    func remove(forKey key: String) throws {
        let url = fileURL(for: key)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
    
    func clearAll() throws {
        if fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.removeItem(at: cacheDirectory)
            createCacheDirectoryIfNeeded()
        }
    }
}
