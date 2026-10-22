import Foundation

protocol MediaRepositoryProtocol: Sendable {
    func upload(
        fileURL: URL,
        title: String,
        contentType: String,
        execution: TransferExecution,
        idempotencyKey: UUID
    ) async throws -> TransferOperation<UploadedMedia>

    func download(_ request: DownloadRequest) async throws -> DownloadOperation

    func resumeDownload(
        _ request: DownloadRequest,
        token: DownloadResumeToken
    ) async throws -> DownloadOperation
}
