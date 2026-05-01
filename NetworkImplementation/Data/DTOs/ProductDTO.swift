//
//  ProductDTO.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct ProductDTO: Codable {
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
}

struct ProductsResponseDTO: Codable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}

struct ProductSearchResponseDTO: Codable {
    let products: [ProductDTO]
    let total: Int
    let skip: Int
    let limit: Int
}
