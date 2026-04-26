//
//  Product.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct Product {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let discountPercentage: Double
    let rating: Double
    let stock: Int
    let brand: String?
    let category: String
    let thumbnail: String
    let images: [String]
    
    var discountedPrice: Double {
        return price - (price * discountPercentage / 100)
    }
    
    var isInStock: Bool {
        return stock > 0
    }
}
