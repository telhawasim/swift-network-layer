//
//  UploadResponseDTO.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

struct UploadResponseDTO: Decodable, Sendable {
    let id: Int
    let url: URL
    let filename: String
}
