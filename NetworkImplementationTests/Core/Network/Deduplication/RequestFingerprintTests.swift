import Foundation
import Testing
@testable import NetworkImplementation

@Suite("Request fingerprint")
struct RequestFingerprintTests {
    private let sut = SHA256RequestFingerprintBuilder()

    @Test("Equivalent requests produce the same fingerprint")
    func equivalentRequestsMatch() throws {
        var first = URLRequest(
            url: try #require(URL(string: "https://example.com/products?limit=10&skip=0"))
        )
        first.httpMethod = "GET"
        first.setValue("application/json", forHTTPHeaderField: "Accept")

        let second = first

        #expect(try sut.fingerprint(for: first) == sut.fingerprint(for: second))
    }

    @Test("Query-item order is normalized")
    func queryOrderDoesNotMatter() throws {
        var first = URLRequest(
            url: try #require(URL(string: "https://example.com/products?limit=10&skip=0"))
        )
        first.httpMethod = "GET"

        var second = URLRequest(
            url: try #require(URL(string: "https://example.com/products?skip=0&limit=10"))
        )
        second.httpMethod = "GET"

        #expect(try sut.fingerprint(for: first) == sut.fingerprint(for: second))
    }

    @Test("Authentication identity participates without being stored directly")
    func authenticationChangesFingerprint() throws {
        let url = try #require(URL(string: "https://example.com/profile"))
        var first = URLRequest(url: url)
        first.httpMethod = "GET"
        first.setValue("Bearer first-token", forHTTPHeaderField: "Authorization")

        var second = URLRequest(url: url)
        second.httpMethod = "GET"
        second.setValue("Bearer second-token", forHTTPHeaderField: "Authorization")

        let firstFingerprint = try sut.fingerprint(for: first)
        let secondFingerprint = try sut.fingerprint(for: second)

        #expect(firstFingerprint != secondFingerprint)
        #expect(!firstFingerprint.rawValue.contains("first-token"))
        #expect(!secondFingerprint.rawValue.contains("second-token"))
    }

    @Test("Different bodies produce different fingerprints")
    func bodyChangesFingerprint() throws {
        let url = try #require(URL(string: "https://example.com/search"))
        var first = URLRequest(url: url)
        first.httpMethod = "GET"
        first.httpBody = Data("first".utf8)

        var second = URLRequest(url: url)
        second.httpMethod = "GET"
        second.httpBody = Data("second".utf8)

        #expect(try sut.fingerprint(for: first) != sut.fingerprint(for: second))
    }
}
