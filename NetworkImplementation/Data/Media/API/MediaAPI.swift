import Foundation

enum MediaAPI {
    static func upload(
        fileURL: URL,
        title: String,
        contentType: String,
        execution: TransferExecution,
        idempotencyKey: UUID
    ) -> MultipartUploadRequest<UploadResponseDTO> {
        MultipartUploadRequest(
            request: APIRequest<UploadResponseDTO>(
                pathComponents: ["media", "upload"],
                method: .post,
                headers: ["Idempotency-Key": idempotencyKey.uuidString],
                authentication: .bearerRequired,
                retryBehavior: .never
            ),
            form: MultipartForm(
                parts: [
                    .text(name: "title", value: title),
                    .file(
                        name: "file",
                        filename: fileURL.lastPathComponent,
                        contentType: contentType,
                        fileURL: fileURL
                    )
                ]
            ),
            execution: execution,
            identifier: idempotencyKey.uuidString
        )
    }

    static func download(
        remoteID: Int,
        destinationDirectory: URL,
        filename: String,
        allowedContentTypes: Set<String>,
        expectedSHA256: String?,
        execution: TransferExecution
    ) -> DownloadRequest {
        DownloadRequest(
            request: APIRequest<EmptyResponse>(
                pathComponents: ["media", String(remoteID), "download"],
                method: .get,
                authentication: .bearerRequired,
                retryBehavior: .never
            ),
            destination: DownloadDestination(
                allowedDirectory: destinationDirectory,
                filename: filename,
                overwriteExistingFile: true
            ),
            validation: DownloadValidationPolicy(
                maximumFileSize: 50 * 1_024 * 1_024,
                allowedContentTypes: allowedContentTypes,
                expectedSHA256: expectedSHA256
            ),
            execution: execution,
            resumeIdentifier: "media-\(remoteID)"
        )
    }
}
