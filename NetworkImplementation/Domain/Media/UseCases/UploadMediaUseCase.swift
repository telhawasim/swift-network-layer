import Foundation

protocol UploadMediaUseCaseProtocol: Sendable {
    func execute(
        fileURL: URL,
        title: String,
        contentType: String,
        execution: TransferExecution
    ) async throws -> TransferOperation<UploadedMedia>
}

struct UploadMediaUseCase: UploadMediaUseCaseProtocol {
    private let repository: any MediaRepositoryProtocol

    init(repository: any MediaRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        fileURL: URL,
        title: String,
        contentType: String,
        execution: TransferExecution = .foreground
    ) async throws -> TransferOperation<UploadedMedia> {
        guard fileURL.isFileURL,
              FileManager.default.fileExists(atPath: fileURL.path) else {
            throw MediaValidationError.invalidFileURL
        }

        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else {
            throw MediaValidationError.emptyTitle
        }

        guard contentType.contains("/"),
              !contentType.contains("\r"),
              !contentType.contains("\n") else {
            throw MediaValidationError.invalidContentType
        }

        return try await repository.upload(
            fileURL: fileURL,
            title: title,
            contentType: contentType,
            execution: execution,
            idempotencyKey: UUID()
        )
    }
}

enum MediaValidationError: Error, Sendable {
    case invalidFileURL
    case emptyTitle
    case invalidContentType
}

extension MediaValidationError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidFileURL: "The selected media file is invalid."
        case .emptyTitle: "A media title is required."
        case .invalidContentType: "The media content type is invalid."
        }
    }
}
