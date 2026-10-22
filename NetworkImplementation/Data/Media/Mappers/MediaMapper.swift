import Foundation

struct MediaMapper: Sendable {
    func toDomain(_ dto: UploadResponseDTO) -> UploadedMedia {
        UploadedMedia(id: dto.id, url: dto.url, filename: dto.filename)
    }
}
