//
//  ProductAPI.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 21/10/2026.
//

import Foundation

enum ProductAPI {

    static func products(limit: Int, skip: Int) -> APIRequest<ProductsResponseDTO> {
        APIRequest(
            pathComponents: ["products"],
            method: .get,
            queryItems: [
                QueryItem("limit", String(limit)),
                QueryItem("skip", String(skip))
            ],
            authentication: .none
        )
    }

    static func product(id: Int) -> APIRequest<ProductDTO> {
        APIRequest(
            pathComponents: ["products", String(id)],
            method: .get,
            authentication: .none
        )
    }

    static func search(query: String) -> APIRequest<ProductSearchResponseDTO> {
        APIRequest(
            pathComponents: ["products", "search"],
            method: .get,
            queryItems: [
                QueryItem("q", query)
            ],
            authentication: .none
        )
    }

    static func category(_ category: String) -> APIRequest<ProductsResponseDTO> {
        APIRequest(
            pathComponents: ["products", "category", category],
            method: .get,
            authentication: .none
        )
    }
}
