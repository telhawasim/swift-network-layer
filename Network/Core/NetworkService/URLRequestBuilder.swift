//
//  URLRequestBuilder.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

protocol URLRequestBuildable {
    func build(from request: NetworkRequest) throws -> URLRequest
}

final class URLRequestBuilder: URLRequestBuildable {
    
    func build(from request: NetworkRequest) throws -> URLRequest {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.timeoutInterval = request.timeout
        
        for header in request.headers.allHeaders {
            urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
        }
        
        try configureTask(&urlRequest, with: request.task)
        return urlRequest
    }
}

// MARK: - HELPER FUNCTIONS -
extension URLRequestBuilder {
    
    /// In order to configure task according to http requirement
    /// - Parameters:
    ///   - urlRequest: `URLRequest` request which needs to be configured
    ///   - task: `HTTPTask` task in which it needs to be configured
    private func configureTask(_ urlRequest: inout URLRequest, with task: HTTPTask) throws {
        switch task {
        case .requestPlain:
            break
            
        case .requestData(let data):
            urlRequest.httpBody = data
            
        case .requestParameters(let parameters, let encoding):
            try encoding.encode(urlRequest: &urlRequest, with: parameters)
            
        case .requestEncodable(let body, let encoder):
            urlRequest.httpBody = try body.toData(encoder: encoder)
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        case .requestCompositeParameters(let bodyParameters, let bodyEncoding, let urlParameters):
            try ParameterEncoding.urlEncoding.encode(urlRequest: &urlRequest, with: urlParameters)
            try bodyEncoding.encode(urlRequest: &urlRequest, with: bodyParameters)
            
        case .requestCompositeEncodable(let body, let urlParameters, let encoder):
            try ParameterEncoding.urlEncoding.encode(urlRequest: &urlRequest, with: urlParams)
            urlRequest.httpBody = try body.toData(encoder: encoder)
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
            
        case .uploadMultipart(let parts):
            let boundary = UUID().uuidString
            urlRequest.setValue(
                "multipart/form-data; boundary=\(boundary)",
                forHTTPHeaderField: "Content-Type"
            )
            urlRequest.httpBody = buildMultipartBody(parts, boundary: boundary)
            
        case .download(let destination):
            break
        }
    }
    
    /// In order to build multi-part
    /// - Parameters:
    ///   - parts: `[MultipartFormData]` all multi-part array object
    ///   - boundary: `String` unique boundary
    /// - Returns: `Data` will return in the form of data
    private func buildMultipartBody(_ parts: [MultipartFormData], boundary: String) -> Data {
        var body = Data()
        
        for part in parts {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(part.name)\"")
            if let fileName = part.fileName {
                body.append("; filename=\"\(fileName)\"")
            }
            body.append("\r\n")
            if let mimeType = part.mimeType {
                body.append("Content-Type: \(mimeType)\r\n")
            }
            body.append("\r\n")
            body.append(part.data)
            body.append("\r\n")
        }
        body.append("--\(boundary)--\r\n")
        return body
    }
}
