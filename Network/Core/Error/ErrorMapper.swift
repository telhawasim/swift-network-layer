//
//  ErrorMapper.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

protocol ErrorMappable {
    func map(_ error: Error) -> NetworkError
}

final class ErrorMapper: ErrorMappable {
    
    func map(_ error: any Error) -> NetworkError {
        switch error {
        case let networkError as NetworkError:
            return networkError
        case let urlError as URLError:
            return mapURLError(urlError)
        case let decodingError as DecodingError:
            return .decodingError(decodingError)
        default:
            return .underlying(error)
        }
    }
}

// MARK: - HELPER FUNCTIONS -
extension ErrorMapper {
    
    /// In order to map URL Error
    /// - Parameter error: `URLError` error which needs to be mapped
    /// - Returns: `NetworkError` after mapping to network error
    private func mapURLError(_ error: URLError) -> NetworkError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .noInternetConnection
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
            return .hostUnreachable
        case .serverCertificateUntrusted, .clientCertificateRejected:
            return .sslError
        default:
            return .underlying(error)
        }
    }
}
