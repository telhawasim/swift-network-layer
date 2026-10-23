//
//  RequestFingerprint.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 22/10/2026.
//

import Foundation
import CryptoKit

struct RequestFingerprint: Hashable, Sendable {
    let rawValue: String
}

protocol RequestFingerprintBuilding: Sendable {
    func fingerprint(for request: URLRequest) throws -> RequestFingerprint
}

struct SHA256RequestFingerprintBuilder: RequestFingerprintBuilding {

    /// Helper Model
    struct NormalizedHeader {
        let name: String
        let value: String
    }

    func fingerprint(for request: URLRequest) throws -> RequestFingerprint {
        guard let url = request.url else {
            throw NetworkError.invalidURL
        }

        let normalizedURL = try normalize(url)
        let method = request.httpMethod?.uppercased() ?? HTTPMethod.get.rawValue
        let headers = normalizeHeaders(from: request)
        let bodyDigest = sha256Hex(request.httpBody ?? Data())

        var canonicalData = Data()

        appendField(name: "method", value: method, to: &canonicalData)
        appendField(name: "url", value: normalizedURL, to: &canonicalData)

        for header in headers {
            appendField(name: "header:\(header.name)", value: header.value, to: &canonicalData)
        }

        appendField(name: "body-sha256", value: bodyDigest, to: &canonicalData)

        return RequestFingerprint(rawValue: sha256Hex(canonicalData))
    }
}

// MARK: - HELPER FUNCTIONS -
extension SHA256RequestFingerprintBuilder {

    private func normalize(_ url: URL) throws -> String {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw NetworkError.invalidURL
        }

        components.fragment = nil
        components.scheme = components.scheme?.lowercased()
        components.host = components.host?.lowercased()

        if components.scheme == "http", components.port == 80 {
            components.port = nil
        }

        if components.scheme == "https", components.port == 443 {
            components.port = nil
        }

        if let queryItems = components.queryItems {
            components.queryItems = queryItems
                .enumerated()
                .sorted { lhs, rhs in
                    if lhs.element.name != rhs.element.name {
                        return lhs.element.name < rhs.element.name
                    }

                    let lhsValue = lhs.element.value ?? ""
                    let rhsValue = rhs.element.value ?? ""

                    if lhsValue != rhsValue {
                        return lhsValue < rhsValue
                    }

                    return lhs.offset < rhs.offset
                }
                .map { $0.element }
        }

        guard let normalizedURL = components.url?.absoluteString else {
            throw NetworkError.invalidURL
        }

        return normalizedURL
    }

    private func normalizeHeaders(from request: URLRequest) -> [NormalizedHeader] {
        (request.allHTTPHeaderFields ?? [:])
            .map { name, value in
                NormalizedHeader(
                    name: name.lowercased(),
                    value: value.trimmingCharacters(in: .whitespacesAndNewlines)
                )
            }
            .sorted { lhs, rhs in
                if lhs.name != rhs.name {
                    return lhs.name < rhs.name
                }

                return lhs.value < rhs.value
            }
    }

    private func appendField(name: String, value: String, to data: inout Data) {
        appendLengthPrefixed(name, to: &data)
        appendLengthPrefixed(value, to: &data)
    }

    private func appendLengthPrefixed(_ value: String, to data: inout Data) {
        let valueData = Data(value.utf8)

        data.append(contentsOf: String(valueData.count).utf8)
        data.append(58)
        data.append(contentsOf: valueData)
        data.append(0)
    }

    private func sha256Hex(_ data: Data) -> String {
        SHA256.hash(data: data)
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
