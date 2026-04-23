//
//  NetworkPlugin.swift
//  Network
//
//  Created by Telha Wasim on 24/04/2026.
//

import Foundation

enum NetworkPluginEvent {
    case willSend(URLRequest)
    case didReceive(URLResponse, Data?)
    case didFail(Error)
}

protocol NetworkPlugin {
    func handle(_ event: NetworkPluginEvent)
}
