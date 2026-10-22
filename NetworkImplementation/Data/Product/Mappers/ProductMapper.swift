import Foundation

struct ProductMapper: Sendable {
    func toDomain(_ dto: ProductDTO) -> Product {
        Product(
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
}
