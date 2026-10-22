import Foundation

actor NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let requestBuilder: any RequestBuilderProtocol
    private let authSession: (any AuthSessionProtocol)?
    private let retryPolicy: any RetryPolicyProtocol
    private let sleeper: any Sleeper
    private let logger: any NetworkLoggerProtocol
    private let decoder: JSONDecoder

    init(
        session: URLSession,
        requestBuilder: any RequestBuilderProtocol,
        authSession: (any AuthSessionProtocol)?,
        retryPolicy: any RetryPolicyProtocol,
        sleeper: any Sleeper = TaskSleeper(),
        logger: any NetworkLoggerProtocol,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.session = session
        self.requestBuilder = requestBuilder
        self.authSession = authSession
        self.retryPolicy = retryPolicy
        self.sleeper = sleeper
        self.logger = logger
        self.decoder = decoder
    }

    func send<Response>(
        _ request: APIRequest<Response>
    ) async throws -> APIResponse<Response> where Response: Decodable & Sendable {
        var retryAttempt = 0
        var didRefreshToken = false

        while true {
            do {
                try Task.checkCancellation()
                let urlRequest = try await requestBuilder.build(request)
                logger.request(urlRequest, attempt: retryAttempt)

                let (data, response) = try await session.data(for: urlRequest)
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponse
                }
                logger.response(httpResponse, data: data)

                if (200...299).contains(httpResponse.statusCode) {
                    return try decode(data, response: httpResponse, as: Response.self)
                }

                let error = makeHTTPError(response: httpResponse, data: data)
                if httpResponse.statusCode == 401,
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

                if httpResponse.statusCode == 401, didRefreshToken {
                    await authSession?.logout()
                    throw NetworkError.authenticationRequired
                }

                guard let delay = retryPolicy.delay(
                    for: request, error: error, attempt: retryAttempt
                ) else {
                    logger.failure(error)
                    throw error
                }
                try await sleeper.sleep(for: delay)
                retryAttempt += 1
            } catch is CancellationError {
                throw NetworkError.cancelled
            } catch let error as NetworkError {
                if case .authenticationRequired = error { throw error }
                if error.statusCode != nil { throw error }

                guard let delay = retryPolicy.delay(
                    for: request, error: error, attempt: retryAttempt
                ) else {
                    logger.failure(error)
                    throw error
                }
                try await sleeper.sleep(for: delay)
                retryAttempt += 1
            } catch let error as URLError {
                let networkError = mapTransportError(error)
                guard let delay = retryPolicy.delay(
                    for: request, error: networkError, attempt: retryAttempt
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

    private func decode<Response>(
        _ data: Data,
        response: HTTPURLResponse,
        as type: Response.Type
    ) throws -> APIResponse<Response> where Response: Decodable & Sendable {
        let value: Response
        if data.isEmpty, let empty = EmptyResponse() as? Response {
            value = empty
        } else {
            do {
                value = try decoder.decode(Response.self, from: data)
            } catch {
                throw NetworkError.responseDecoding(error.localizedDescription)
            }
        }

        return APIResponse(
            value: value,
            statusCode: response.statusCode,
            headers: stringHeaders(from: response)
        )
    }

    private func makeHTTPError(response: HTTPURLResponse, data: Data) -> NetworkError {
        let message = try? decoder.decode(ErrorResponseDTO.self, from: data).message
        return .http(
            statusCode: response.statusCode,
            message: message,
            retryAfter: retryAfter(from: response)
        )
    }

    private func mapTransportError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .cancelled: return .cancelled
        case .notConnectedToInternet: return .offline
        case .timedOut: return .timedOut
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

    private func stringHeaders(from response: HTTPURLResponse) -> [String: String] {
        response.allHeaderFields.reduce(into: [:]) { result, entry in
            result[String(describing: entry.key)] = String(describing: entry.value)
        }
    }

    private func retryAfter(from response: HTTPURLResponse) -> TimeInterval? {
        guard let value = response.value(forHTTPHeaderField: "Retry-After") else { return nil }
        if let seconds = TimeInterval(value) { return seconds }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss z"
        return formatter.date(from: value).map { max(0, $0.timeIntervalSinceNow) }
    }
}
