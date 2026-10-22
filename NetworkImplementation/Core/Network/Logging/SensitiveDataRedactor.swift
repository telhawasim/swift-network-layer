//
//  SensitiveDataRedactor.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 20/10/2026.
//

import Foundation

struct SensitiveDataRedactor: Sendable {

    // MARK: - PROPERTIES -

    /// Normal
    private let sensitiveKeys: Set<String> = [
        "authorization",
        "cookie",
        "set_cookie",
        "password",
        "passcode",
        "token",
        "access_token",
        "accesstoken",
        "refresh_token",
        "refreshtoken",
        "api_key",
        "apikey",
        "api_secret",
        "cardnumber",
        "card_number",
        "credit_card",
        "cvv",
        "ssn",
        "email",
        "phone",
        "address",
        "postalcode",
        "postal_code",
        "firstname",
        "first_name",
        "lastname",
        "last_name",
        "username"
    ]

    func headers(_ headers: [String: String]) -> [String: String] {
        headers.mapValues { $0 }.reduce(into: [:]) { result, entry in
            result[entry.key] = isSensitive(entry.key) ? "<redacted>" : entry.value
        }
    }

    func url(_ url: URL?) -> String {
        guard let url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return "<invalid-url>"
        }

        components.queryItems = components.queryItems?.map { item in
            URLQueryItem(name: item.name, value: item.value == nil ? nil : "<redacted>")
        }

        return components.url?.absoluteString ?? "<invalid-url>"
    }

    func body(_ data: Data?, maximumBytes: Int = 16_384) -> String {
        guard let data else {
            return "<empty>"
        }

        guard data.count <= maximumBytes else {
            return "<\(data.count) bytes omitted>"
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) else {
            return "<\(data.count) non-JSON bytes>"
        }

        let redactedJSON = redact(json)

        guard let output = try? JSONSerialization.data(
            withJSONObject: redactedJSON,
            options: [.prettyPrinted, .sortedKeys]
        ) else {
            return "<unavailable>"
        }

        return String(decoding: output, as: UTF8.self)
    }
}

// MARK: - HELPER FUNCTIONS -
extension SensitiveDataRedactor {

    private func redact(_ value: Any) -> Any {
        if let dictionary = value as? [String: Any] {
            return dictionary.reduce(into: [String: Any]()) { result, entry in
                result[entry.key] = isSensitive(entry.key) ? "<redacted>" : redact(entry.value)
            }
        }

        if let array = value as? [Any] {
            return array.map(redact)
        }

        return value
    }

    private func isSensitive(_ key: String) -> Bool {
        sensitiveKeys.contains(key.lowercased().replacingOccurrences(of: "-", with: "_"))
    }
}
