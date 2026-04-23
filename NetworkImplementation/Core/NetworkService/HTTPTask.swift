//
//  HTTPTask.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

typealias Parameters = [String: Any]

/// Enum for HTTP Task
enum HTTPTask {
    case requestPlain
    case requestData(Data)
    case requestParameters(parameters: Parameters, encoding: ParameterEncoding)
    case requestEncodable(body: Encodable, encoder: JSONEncoder = .init())
    case requestCompositeParameters(
        bodyParameters: Parameters,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters
    )
    case requestCompositeEncodable(
        body: Encodable,
        urlParameters: Parameters,
        encoder: JSONEncoder = .init()
    )
    case uploadMultipart([MultipartFormData])
    case download(destination: URL)
}

/// Enum for Parameter Encoding
enum ParameterEncoding {
    case urlEncoding
    case jsonEncoding
    case urlEncodedFormEncoding
    
    /// In order to encode the parameters according to the type
    /// - Parameters:
    ///   - urlRequest: `URLRequest` request which needs to be encoded
    ///   - parameters: `Parameters` params `[String: Any]`
    func encode(urlRequest: inout URLRequest, with parameters: Parameters) throws {
        switch self {
        case .urlEncoding:
            guard let url = urlRequest.url else {
                throw NetworkError.invalidURL
            }
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let queryItems = parameters.map {
                URLQueryItem(name: $0.key, value: "\($0.value)")
            }
            components?.queryItems = (components?.queryItems ?? []) + queryItems
            urlRequest.url = components?.url
            
        case .jsonEncoding:
            let data = try JSONSerialization.data(withJSONObject: parameters)
            urlRequest.httpBody = data
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
        case .urlEncodedFormEncoding:
            let paramString = parameters
                .map { key, value -> String in
                    let k = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? key
                    let v = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "\(value)"
                    return "\(k)=\(v)"
                }
                .joined(separator: "&")
            urlRequest.httpBody = paramString.data(using: .utf8)
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue(
                    "application/x-www-form-urlencoded",
                    forHTTPHeaderField: "Content-Type"
                )
            }
        }
    }
}
