//
//  ProductEndpoint.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

enum ProductEndpoint: Endpoint {
    case getProducts(limit: Int, skip: Int)
    case getProduct(id: Int)
    case searchProducts(query: String)
    case getProductsByCategory(category: String)
    
    var baseURL: String {
        return APIConfiguration.baseURL
    }
    
    var path: String {
        switch self {
        case .getProducts:
            return "/products"
        case .getProduct(let id):
            return "/products/\(id)"
        case .searchProducts(let query):
            return "/products/search"
        case .getProductsByCategory(let category):
            return "/products/category/\(category)"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var task: HTTPTask {
        switch self {
        case .getProducts(let limit, let skip):
            let parameters: [String: Any] = [
                "limit": limit,
                "skip": skip
            ]
            return .requestParameters(bodyParameters: nil, urlParameters: parameters)
            
        case .getProduct(let id):
            return .request
            
        case .searchProducts(let query):
            let parameter: [String: Any] = [
                "q": query
            ]
            return .requestParameters(bodyParameters: nil, urlParameters: parameter)
            
        case .getProductsByCategory(let category):
            return .request
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
