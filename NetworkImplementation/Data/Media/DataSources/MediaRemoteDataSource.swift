import Foundation

protocol MediaRemoteDataSourceProtocol: Sendable {
    func upload(
        fileURL: URL,
        title: String,
        contentType: String,
        execution: TransferExecution,
        idempotencyKey: UUID
    ) async throws -> TransferOperation<APIResponse<UploadResponseDTO>>

    func download(_ request: DownloadRequest) async throws -> DownloadOperation

    func resumeDownload(
        _ request: DownloadRequest,
        token: DownloadResumeToken
    ) async throws -> DownloadOperation
}

struct MediaRemoteDataSource: MediaRemoteDataSourceProtocol {
    private let transferClient: any FileTransferClientProtocol

    init(transferClient: any FileTransferClientProtocol) {
        self.transferClient = transferClient
    }

    func upload(
        fileURL: URL,
        title: String,
        contentType: String,
        execution: TransferExecution,
        idempotencyKey: UUID
    ) async throws -> TransferOperation<APIResponse<UploadResponseDTO>> {
        try await transferClient.upload(
            MediaAPI.upload(
                fileURL: fileURL,
                title: title,
                contentType: contentType,
                execution: execution,
                idempotencyKey: idempotencyKey
            )
        )
    }

    func download(_ request: DownloadRequest) async throws -> DownloadOperation {
        try await transferClient.download(request)
    }

    func resumeDownload(
        _ request: DownloadRequest,
        token: DownloadResumeToken
    ) async throws -> DownloadOperation {
        try await transferClient.resumeDownload(request, token: token)
    }
}
