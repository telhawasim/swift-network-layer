//
//  AuthEndpoint.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

enum AuthEndpoint: Endpoint {
    case login(request: LoginRequestDTO)
    case getCurrentUser
    case refreshToken(token: String)
    
    var baseURL: String {
        return APIConfiguration.baseURL
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .getCurrentUser:
            return "/auth/me"
        case .refreshToken(let token):
            return "/auth/refresh"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .refreshToken:
            return .post
        case .getCurrentUser:
            return .get
        }
    }
    
    var task: HTTPTask {
        switch self {
        case .login(let request):
            let parameters: [String: Any] = [
                "username": request.username,
                "password": request.password
            ]
            return .requestParameters(bodyParameters: parameters, urlParameters: nil)
        case .getCurrentUser:
            return .request
        case .refreshToken(let token):
            let parameters: [String: Any] = [
                "refreshToken": token
            ]
            return .requestParameters(bodyParameters: parameters, urlParameters: nil)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-Type": "application/json"
        ]
    }
}
