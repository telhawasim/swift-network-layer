import Foundation

struct UserMapper: Sendable {
    func toDomain(_ dto: UserDTO) -> User {
        User(
            id: dto.id,
            firstName: dto.firstName,
            lastName: dto.lastName,
            email: dto.email,
            phone: dto.phone,
            image: dto.image,
            address: User.Address(
                street: dto.address.address,
                city: dto.address.city,
                state: dto.address.state,
                postalCode: dto.address.postalCode,
                country: dto.address.country
            )
        )
    }
}
