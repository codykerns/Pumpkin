//
//  PumpkinDefaults.swift
//  Pumpkin
//
//  Created by Cody Kerns on 11/22/25.
//

import Foundation

public enum ClearOption: Sendable {
    case all
    case headers
    case baseUrl
}

public actor PumpkinDefaults {
    private var baseURL: String?
    private var headers: [String: String] = [:]

    internal init() {}

    public func set(baseUrl: String) {
        self.baseURL = baseUrl
    }

    public func set(header key: String, _ value: String) {
        headers[key] = value
    }

    public func set(header type: HeaderType, _ value: String) {
        headers[type.key] = type.value(with: value)
    }

    public func clear(_ option: ClearOption = .all) {
        switch option {
        case .all:
            baseURL = nil
            headers.removeAll()
        case .headers:
            headers.removeAll()
        case .baseUrl:
            baseURL = nil
        }
    }

    internal func getBaseURL() -> String? {
        return baseURL
    }

    internal func getHeaders() -> [String: String] {
        return headers
    }
}
