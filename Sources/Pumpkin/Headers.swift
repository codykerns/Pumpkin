//
//  Headers.swift
//  Pumpkin
//
//  Created by Cody Kerns on 11/22/25.
//

import Foundation

public enum HeaderType {
    case bearer
    case basic
    case apiKey
    case contentType(String)
    case accept(String)

    var key: String {
        switch self {
        case .bearer, .basic:
            return "Authorization"
        case .apiKey:
            return "X-API-Key"
        case .contentType:
            return "Content-Type"
        case .accept:
            return "Accept"
        }
    }

    func value(with token: String) -> String {
        switch self {
        case .bearer:
            return "Bearer \(token)"
        case .basic:
            return "Basic \(token)"
        case .apiKey:
            return token
        case .contentType(let type):
            return type
        case .accept(let type):
            return type
        }
    }
}
