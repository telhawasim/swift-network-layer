import Foundation

struct MediaRepositoryImpl: MediaRepositoryProtocol {
    private let remote: any MediaRemoteDataSourceProtocol
    private let mapper: MediaMapper

    init(
        remote: any MediaRemoteDataSourceProtocol,
        mapper: MediaMapper = MediaMapper()
    ) {
        self.remote = remote
        self.mapper = mapper
    }

    func upload(
        fileURL: URL,
        title: String,
        contentType: String,
        execution: TransferExecution,
        idempotencyKey: UUID
    ) async throws -> TransferOperation<UploadedMedia> {
        let operation = try await remote.upload(
            fileURL: fileURL,
            title: title,
            contentType: contentType,
            execution: execution,
            idempotencyKey: idempotencyKey
        )

        return operation.map { response in
            mapper.toDomain(response.value)
        }
    }

    func download(_ request: DownloadRequest) async throws -> DownloadOperation {
        try await remote.download(request)
    }

    func resumeDownload(
        _ request: DownloadRequest,
        token: DownloadResumeToken
    ) async throws -> DownloadOperation {
        try await remote.resumeDownload(request, token: token)
    }
}
