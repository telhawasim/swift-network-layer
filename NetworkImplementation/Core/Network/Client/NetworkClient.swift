import Foundation

actor NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let requestBuilder: any RequestBuilderProtocol
    private let authSession: (any AuthSessionProtocol)?
    private let retryPolicy: any RetryPolicyProtocol
    private let fingerprintBuilder: any RequestFingerprintBuilding
    private let inFlightRequestStore: any InFlightRequestStoring
    private let sleeper: any Sleeper
    private let logger: any NetworkLoggerProtocol
    private let decoder: JSONDecoder

    init(
        session: URLSession,
        requestBuilder: any RequestBuilderProtocol,
        authSession: (any AuthSessionProtocol)?,
        retryPolicy: any RetryPolicyProtocol,
        fingerprintBuilder: any RequestFingerprintBuilding,
        inFlightRequestStore: any InFlightRequestStoring,
        sleeper: any Sleeper = TaskSleeper(),
        logger: any NetworkLoggerProtocol,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.session = session
        self.requestBuilder = requestBuilder
        self.authSession = authSession
        self.retryPolicy = retryPolicy
        self.fingerprintBuilder = fingerprintBuilder
        self.inFlightRequestStore = inFlightRequestStore
        self.sleeper = sleeper
        self.logger = logger
        self.decoder = decoder
    }

    func send<Response>(
        _ request: APIRequest<Response>
    ) async throws -> APIResponse<Response> where Response: Decodable & Sendable {
        do {
            try Task.checkCancellation()

            // Fingerprint the fully adapted request so URL, headers, body, and auth identity match.
            let initialURLRequest = try await requestBuilder.build(request)
            let rawResponse: RawHTTPResponse

            if request.deduplicationPolicy.allowsSharing(for: request.method) {
                let fingerprint = try fingerprintBuilder.fingerprint(for: initialURLRequest)
                rawResponse = try await inFlightRequestStore.response(for: fingerprint) { [self] in
                    try await execute(request, initialURLRequest: initialURLRequest)
                }
            } else {
                rawResponse = try await execute(request, initialURLRequest: initialURLRequest)
            }

            return try decode(rawResponse, as: Response.self)
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch let error as NetworkError {
            throw error
        } catch let error as URLError {
            throw mapTransportError(error)
        } catch {
            throw NetworkError.transport(
                code: (error as NSError).code,
                description: error.localizedDescription
            )
        }
    }
}

// MARK: - Request Execution

private extension NetworkClient {
    func execute<Response>(
        _ request: APIRequest<Response>,
        initialURLRequest: URLRequest
    ) async throws -> RawHTTPResponse where Response: Decodable & Sendable {
        var retryAttempt = 0
        var didRefreshToken = false
        var pendingInitialRequest: URLRequest? = initialURLRequest

        while true {
            do {
                try Task.checkCancellation()

                let urlRequest: URLRequest
                if let initialRequest = pendingInitialRequest {
                    urlRequest = initialRequest
                    pendingInitialRequest = nil
                } else {
                    // Rebuild after a retry or refresh so the latest token is applied.
                    urlRequest = try await requestBuilder.build(request)
                }

                logger.request(urlRequest, attempt: retryAttempt)

                let (data, response) = try await session.data(for: urlRequest)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }

                logger.response(httpResponse, data: data)
                let rawResponse = RawHTTPResponse(data: data, response: httpResponse)

                if (200...299).contains(rawResponse.statusCode) {
                    return rawResponse
                }

                let networkError = makeHTTPError(from: rawResponse)

                if rawResponse.statusCode == 401,
                   request.authentication.usesBearerToken,
                   !didRefreshToken,
                   let authSession {
                    do {
                        _ = try await authSession.refreshAccessToken(
                            rejectedAccessToken: urlRequest.bearerToken
                        )
                        didRefreshToken = true
                        continue
                    } catch is CancellationError {
                        throw CancellationError()
                    } catch {
                        await authSession.logout()
                        throw NetworkError.authenticationRequired
                    }
                }

                if rawResponse.statusCode == 401, didRefreshToken {
                    await authSession?.logout()
                    throw NetworkError.authenticationRequired
                }

                guard let delay = retryPolicy.delay(
                    for: request,
                    error: networkError,
                    attempt: retryAttempt
                ) else {
                    logger.failure(networkError)
                    throw networkError
                }

                try await sleeper.sleep(for: delay)
                retryAttempt += 1
            } catch is CancellationError {
                throw NetworkError.cancelled
            } catch let error as NetworkError {
                if case .authenticationRequired = error {
                    throw error
                }

                // HTTP failures have already gone through the retry policy above.
                if error.statusCode != nil {
                    throw error
                }

                guard let delay = retryPolicy.delay(
                    for: request,
                    error: error,
                    attempt: retryAttempt
                ) else {
                    logger.failure(error)
                    throw error
                }

                try await sleeper.sleep(for: delay)
                retryAttempt += 1
            } catch let error as URLError {
                let networkError = mapTransportError(error)
                guard let delay = retryPolicy.delay(
                    for: request,
                    error: networkError,
                    attempt: retryAttempt
                ) else {
                    logger.failure(networkError)
                    throw networkError
                }

                try await sleeper.sleep(for: delay)
                retryAttempt += 1
            } catch {
                let networkError = NetworkError.transport(
                    code: (error as NSError).code,
                    description: error.localizedDescription
                )
                logger.failure(networkError)
                throw networkError
            }
        }
    }
}

// MARK: - Response Decoding

private extension NetworkClient {
    func decode<Response>(
        _ response: RawHTTPResponse,
        as type: Response.Type
    ) throws -> APIResponse<Response> where Response: Decodable & Sendable {
        let value: Response

        if response.data.isEmpty, let empty = EmptyResponse() as? Response {
            value = empty
        } else {
            do {
                value = try decoder.decode(Response.self, from: response.data)
            } catch {
                let networkError = NetworkError.responseDecoding(error.localizedDescription)
                logger.failure(networkError)
                throw networkError
            }
        }

        return APIResponse(
            value: value,
            statusCode: response.statusCode,
            headers: response.headers
        )
    }
}

// MARK: - Error Mapping

private extension NetworkClient {
    func makeHTTPError(from response: RawHTTPResponse) -> NetworkError {
        let message = try? decoder.decode(ErrorResponseDTO.self, from: response.data).message
        return .http(
            statusCode: response.statusCode,
            message: message,
            retryAfter: retryAfter(from: response)
        )
    }

    func mapTransportError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .cancelled:
            return .cancelled
        case .notConnectedToInternet:
            return .offline
        case .timedOut:
            return .timedOut
        case .secureConnectionFailed,
             .serverCertificateHasBadDate,
             .serverCertificateUntrusted,
             .serverCertificateNotYetValid,
             .clientCertificateRejected,
             .clientCertificateRequired:
            return .tlsFailure
        default:
            return .transport(code: error.errorCode, description: error.localizedDescription)
        }
    }

    func retryAfter(from response: RawHTTPResponse) -> TimeInterval? {
        guard let value = response.headerValue(for: "Retry-After") else {
            return nil
        }

        if let seconds = TimeInterval(value) {
            return seconds
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        return formatter.date(from: value).map { max(0, $0.timeIntervalSinceNow) }
    }
}
