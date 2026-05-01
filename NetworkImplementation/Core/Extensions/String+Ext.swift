//
//  String+Ext.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 01/05/2026.
//

import Foundation

extension String {
    
    var sha256Hash: String {
        let data = Data(self.utf8)
        var hash = [UInt8](repeating: 0, count: 32)
        
        data.withUnsafeBytes { bufferPointer in
            let bytes = bufferPointer.bindMemory(to: UInt8.self)
            
            /// Simple hash for file naming (use CryptoKit in production)
            var h: UInt64 = 14695981039346656037
            for i in 0..<bytes.count {
                h ^= UInt64(bytes[i])
                h &*= 1099511628211
            }
            withUnsafeBytes(of: h) { hasBytes in
                for (i, byte) in hasBytes.enumerated() where i < 32 {
                    hash[i % 8] ^= byte
                }
            }
        }
        
        return hash.prefix(16).map { String(format: "%02x", $0) }.joined()
    }
}
