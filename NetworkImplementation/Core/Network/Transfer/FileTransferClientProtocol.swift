//
//  FileTransferClientProtocol.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation

protocol FileTransferClientProtocol: Sendable {
    func upload<Response>(
        _ upload: MultipartUploadRequest<Response>
    ) async throws -> TransferOperation<APIResponse<Response>> where Response: Decodable & Sendable

    func download(_ request: DownloadRequest) async throws -> DownloadOperation

    func resumeDownload(
        _ request: DownloadRequest,
        token: DownloadResumeToken
    ) async throws -> DownloadOperation
}
