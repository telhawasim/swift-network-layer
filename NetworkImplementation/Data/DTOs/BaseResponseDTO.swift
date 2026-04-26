//
//  BaseResponseDTO.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct BaseResponseDTO<T: Decodable>: Decodable {
    let data: T?
    let message: String?
    let success: Bool?
}

struct PaginatedResponseDTO<T: Decodable>: Decodable {
    let items: [T]
    let total: Int
    let skip: Int
    let limit: Int
}

struct ErrorResponseDTO: Decodable {
    let message: String
}
