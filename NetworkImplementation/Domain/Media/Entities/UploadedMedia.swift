import Foundation

struct UploadedMedia: Sendable, Equatable {
    let id: Int
    let url: URL
    let filename: String
}
