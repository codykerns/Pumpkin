//
//  HTTP.swift
//  PumpkinAPI
//
//  Created by Cody Kerns on 11/22/25.
//

public enum HTTPMethod {
    case get
    case post
    case put
    case delete
    case patch
    
    var rawValue: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        case .put: return "PUT"
        case .delete: return "DELETE"
        case .patch: return "PATCH"
        }
    }
}
