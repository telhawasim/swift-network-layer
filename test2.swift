import Foundation

public enum LogLevel: Int, Sendable { case error }

public protocol NetworkLoggerProtocol: Sendable {
    func log(_ message: String, level: LogLevel, file: String, function: String, line: Int)
}

public extension NetworkLoggerProtocol {
    func log(_ message: String, level: LogLevel, file: String = #file, function: String = #function, line: Int = #line) {
        // This actually calls the protocol requirement because the protocol requirement takes 5 arguments
        // and doesn't have default parameters! Wait, Swift compiler might think this is a recursive call.
        // Let's test it.
        log(message, level: level, file: file, function: function, line: line)
    }
}

public actor NetworkLogger: NetworkLoggerProtocol {
    public static let shared = NetworkLogger()
    public nonisolated func log(
        _ message: String,
        level: LogLevel,
        file: String,
        function: String,
        line: Int
    ) {
        print("Logged: \(message) at \(file):\(line)")
    }
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

let pinner = CertificatePinner()
Task {
    await pinner.test()
}
RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
