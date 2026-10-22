import Foundation

struct EncodedMultipartFile: Sendable {
    let url: URL
    let contentType: String
    let contentLength: Int64

    var cleanupIdentifier: String { url.lastPathComponent }
}

actor MultipartFormEncoder {
    static let directoryName = "MultipartUploads"

    private let fileManager: FileManager
    private let temporaryDirectory: URL

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        temporaryDirectory = fileManager.temporaryDirectory
            .appendingPathComponent(Self.directoryName, isDirectory: true)
    }

    func encode(_ form: MultipartForm) throws -> EncodedMultipartFile {
        guard !form.parts.isEmpty else {
            throw TransferError.emptyMultipartForm
        }

        try fileManager.createDirectory(
            at: temporaryDirectory,
            withIntermediateDirectories: true,
            attributes: [
                .protectionKey: FileProtectionType.completeUntilFirstUserAuthentication
            ]
        )

        let boundary = "Boundary-\(UUID().uuidString)"
        let outputURL = temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("multipart")

        guard fileManager.createFile(atPath: outputURL.path, contents: nil) else {
            throw TransferError.temporaryFileCreationFailed
        }

        let handle = try FileHandle(forWritingTo: outputURL)

        do {
            for part in form.parts {
                try write(part, boundary: boundary, to: handle)
            }

            try write("--\(boundary)--\r\n", to: handle)
            try handle.synchronize()
            try handle.close()
        } catch {
            try? handle.close()
            try? fileManager.removeItem(at: outputURL)
            throw error
        }

        let attributes = try fileManager.attributesOfItem(atPath: outputURL.path)
        let size = (attributes[.size] as? NSNumber)?.int64Value ?? 0

        return EncodedMultipartFile(
            url: outputURL,
            contentType: "multipart/form-data; boundary=\(boundary)",
            contentLength: size
        )
    }

    func remove(_ encodedFile: EncodedMultipartFile) {
        try? fileManager.removeItem(at: encodedFile.url)
    }

    private func write(
        _ part: MultipartPart,
        boundary: String,
        to handle: FileHandle
    ) throws {
        try write("--\(boundary)\r\n", to: handle)

        switch part {
        case .text(let name, let value):
            let safeName = try validatedHeaderValue(name, field: "name")
            try write(
                "Content-Disposition: form-data; name=\"\(safeName)\"\r\n\r\n",
                to: handle
            )
            try write(value, to: handle)
            try write("\r\n", to: handle)

        case .file(let name, let filename, let contentType, let fileURL):
            let safeName = try validatedHeaderValue(name, field: "name")
            let safeFilename = try validatedFilename(filename)
            let safeContentType = try validatedContentType(contentType)

            guard fileURL.isFileURL,
                  fileManager.fileExists(atPath: fileURL.path) else {
                throw CocoaError(.fileNoSuchFile)
            }

            try write(
                "Content-Disposition: form-data; name=\"\(safeName)\"; filename=\"\(safeFilename)\"\r\n",
                to: handle
            )
            try write("Content-Type: \(safeContentType)\r\n\r\n", to: handle)
            try copyFile(from: fileURL, to: handle)
            try write("\r\n", to: handle)
        }
    }

    private func copyFile(from source: URL, to destination: FileHandle) throws {
        let hasSecurityScope = source.startAccessingSecurityScopedResource()
        defer {
            if hasSecurityScope {
                source.stopAccessingSecurityScopedResource()
            }
        }

        let input = try FileHandle(forReadingFrom: source)
        defer { try? input.close() }

        while true {
            let data = try input.read(upToCount: 64 * 1_024) ?? Data()
            guard !data.isEmpty else { break }
            try destination.write(contentsOf: data)
        }
    }

    private func write(_ value: String, to handle: FileHandle) throws {
        try handle.write(contentsOf: Data(value.utf8))
    }

    private func validatedHeaderValue(_ value: String, field: String) throws -> String {
        guard !value.isEmpty,
              !value.contains("\r"),
              !value.contains("\n") else {
            throw TransferError.invalidMultipartField(field)
        }

        return value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
    }

    private func validatedFilename(_ filename: String) throws -> String {
        guard filename == URL(fileURLWithPath: filename).lastPathComponent,
              filename != ".",
              filename != ".." else {
            throw TransferError.invalidMultipartField("filename")
        }

        return try validatedHeaderValue(filename, field: "filename")
    }

    private func validatedContentType(_ contentType: String) throws -> String {
        guard !contentType.isEmpty,
              !contentType.contains("\r"),
              !contentType.contains("\n"),
              contentType.contains("/") else {
            throw TransferError.invalidMultipartField("contentType")
        }

        return contentType
    }
}
