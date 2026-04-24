import Foundation

public enum LogLevel: Int, Sendable { case error }

public protocol NetworkLoggerProtocol: Sendable {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

public actor NetworkLogger: NetworkLoggerProtocol {
    public static let shared = NetworkLogger()
    public nonisolated func log(
        _ message: String,
        level: LogLevel,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {}
}

public actor CertificatePinner {
    private let logger: NetworkLoggerProtocol
    public init(logger: NetworkLoggerProtocol = NetworkLogger.shared) {
        self.logger = logger
    }
    public func test() {
        logger.log("msg", level: .error)
    }
}
