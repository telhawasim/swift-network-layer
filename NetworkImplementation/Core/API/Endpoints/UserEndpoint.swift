//
//  UserEndpoint.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

enum UserEndpoint: Endpoint {
    case getUsers(limit: Int, skip: Int)
    case getUser(id: Int)
    case searchUsers(query: String)
    
    var baseURL: String {
        return APIConfiguration.baseURL
    }
    
    var path: String {
        switch self {
        case .getUsers:
            return "/users"
        case .getUser(let id):
            return "/users/\(id)"
        case .searchUsers:
            return "/users/search"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .getUsers(let limit, let skip):
            let paramaters: [String: Any] = [
                "limit": limit,
                "skip": skip
            ]
            return .requestParameters(bodyParameters: nil, urlParameters: paramaters)
        
        case .getUser:
            return .request
            
        case .searchUsers(let query):
            let parameters: [String: Any] = [
                "q": query
            ]
            return .requestParameters(bodyParameters: nil, urlParameters: parameters)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
