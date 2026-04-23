//
//  HTTPTask.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

typealias Parameters = [String: Any]

enum HTTPTask {
    case requestPlain
    case requestData(Data)
    case requestParameters(parameters: Parameters, encoding: ParameterEncoding)
}
