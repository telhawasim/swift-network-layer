//
//  ServerTrustEvaluator.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation
import Security
import CryptoKit

struct ServerTrustEvaluation {

    // MARK: - PROPERTIES -

    /// Normal
    let disposition: URLSession.AuthChallengeDisposition
    let credential: URLCredential?
}

struct ServerTrustEvaluator: Sendable {

    // MARK: - PROPERTIES -

    /// Private
    private let configuration: PinningConfiguration

    // MARK: - INITIALIZER -
    init(configuration: PinningConfiguration) {
        self.configuration = configuration
    }

    func evaluate(_ challenge: URLAuthenticationChallenge) -> ServerTrustEvaluation {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            return ServerTrustEvaluation(disposition: .performDefaultHandling, credential: nil)
        }

        let host = challenge.protectionSpace.host.lowercased()

        guard let expectedPins = configuration.pins(for: host) else {
            return ServerTrustEvaluation(disposition: .performDefaultHandling, credential: nil)
        }

        guard let trust = challenge.protectionSpace.serverTrust else {
            return rejected()
        }

        var trustError: CFError?

        guard SecTrustEvaluateWithError(trust, &trustError),
              let certificates = SecTrustCopyCertificateChain(trust) as? [SecCertificate] else {
            return rejected()
        }

        let receivedPins = Set(
            certificates.map { certificate in
                let certificateData = SecCertificateCopyData(certificate) as Data

                return Data(SHA256.hash(data: certificateData)).base64EncodedString()
            }
        )

        guard !receivedPins.isDisjoint(with: expectedPins) else {
            return rejected()
        }

        return ServerTrustEvaluation(
            disposition: .useCredential,
            credential: URLCredential(trust: trust)
        )
    }
}

// MARK: - HELPER FUNCTIONS -
extension ServerTrustEvaluator {

    private func rejected() -> ServerTrustEvaluation {
        ServerTrustEvaluation(disposition: .cancelAuthenticationChallenge, credential: nil)
    }
}
