//
//  ProductMapper.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

import Foundation

protocol ProductMapperProtocol {
    func toDomain(_ dto: ProductDTO) -> Product
    func ToDomainArray(_ dtos: [ProductDTO]) -> [Product]
}

final class ProductMapper: ProductMapperProtocol {
    func toDomain(_ dto: ProductDTO) -> Product {
        return Product(
            id: dto.id,
            title: dto.title,
            description: dto.description,
            price: dto.price,
            discountPercentage: dto.discountPercentage,
            rating: dto.rating,
            stock: dto.stock,
            brand: dto.brand,
            category: dto.category,
            thumbnail: dto.thumbnail,
            images: dto.images
        )
    }
    
    func ToDomainArray(_ dtos: [ProductDTO]) -> [Product] {
        return dtos.map { toDomain($0) }
    }
}
