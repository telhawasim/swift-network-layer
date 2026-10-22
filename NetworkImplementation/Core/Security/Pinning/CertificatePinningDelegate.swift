import Foundation

final class CertificatePinningDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {
    private let evaluator: ServerTrustEvaluator

    init(configuration: PinningConfiguration) {
        evaluator = ServerTrustEvaluator(configuration: configuration)
    }

    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (
            URLSession.AuthChallengeDisposition,
            URLCredential?
        ) -> Void
    ) {
        let evaluation = evaluator.evaluate(challenge)
        completionHandler(evaluation.disposition, evaluation.credential)
    }
}
