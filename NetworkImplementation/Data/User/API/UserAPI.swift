//
//  UserAPI.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 21/10/2026.
//

import Foundation

enum UserAPI {

    static func users(limit: Int, skip: Int) -> APIRequest<UsersResponseDTO> {
        APIRequest(
            pathComponents: ["users"],
            method: .get,
            queryItems: [
                QueryItem("limit", String(limit)),
                QueryItem("skip", String(skip))
            ],
            authentication: .none
        )
    }

    static func user(id: Int) -> APIRequest<UserDTO> {
        APIRequest(
            pathComponents: ["users", String(id)],
            method: .get,
            authentication: .none
        )
    }

    static func search(query: String) -> APIRequest<UsersResponseDTO> {
        APIRequest(
            pathComponents: ["users", "search"],
            method: .get,
            queryItems: [
                QueryItem("q", query)
            ],
            authentication: .none
        )
    }
}
