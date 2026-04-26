//
//  User.swift
//  NetworkImplementation
//
//  Created by Telha Wasim on 25/04/2026.
//

import Foundation

struct User {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let phone: String
    let username: String
    let age: Int
    let gender: String
    let image: String
    let address: Address?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

struct Address {
    let address: String
    let city: String
    let state: String
    let postalCode: String
    let latitude: Double
    let longitude: Double
    
    var fullAddress: String {
        return "\(address), \(city), \(state) \(postalCode)"
    }
}
