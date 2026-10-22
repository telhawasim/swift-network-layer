import Foundation

protocol DownloadMediaUseCaseProtocol: Sendable {
    func execute(_ request: DownloadRequest) async throws -> DownloadOperation
    func resume(
        _ request: DownloadRequest,
        token: DownloadResumeToken
    ) async throws -> DownloadOperation
}

struct DownloadMediaUseCase: DownloadMediaUseCaseProtocol {
    private let repository: any MediaRepositoryProtocol

    init(repository: any MediaRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ request: DownloadRequest) async throws -> DownloadOperation {
        try await repository.download(request)
    }

    func resume(
        _ request: DownloadRequest,
        token: DownloadResumeToken
    ) async throws -> DownloadOperation {
        try await repository.resumeDownload(request, token: token)
    }
}
