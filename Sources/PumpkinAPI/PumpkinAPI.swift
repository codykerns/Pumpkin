//
//  PumpkinAPI.swift
//  PumpkinAPI
//
//  Created by Cody Kerns on 11/22/25.
//

import Foundation

public class Pumpkin {
    
    /// Entrypoint for setting global configuration on `Pumpkin` requests.
    public static let defaults = PumpkinDefaults()
    
    /// Entrypoint for creating new `Pumpkin` request instances.
    public static var request: Pumpkin {
        Pumpkin()
    }
    
    // Pumpkin properties
    private var urlString: String?
    private var pathString: String?
    private var headers: [String: String] = [:]
    private var queryParameters: [String: String] = [:]
    private var body: Data?
    private var timeoutInterval: TimeInterval = 60.0
    private var ignoredHeaders: Set<String> = []
    
    private init() {}
    
}

/// Request builder methods
extension Pumpkin {
    
    /// Set the full URL for the request.
    /// - Parameter urlString: the URL to use in the request
    /// - Returns: a `Pumpkin` request instance
    public func url(_ urlString: String) -> Self {
        self.urlString = urlString
        return self
    }

    /// Set the path to use appended to the baseURL that is set in `Pumpkin.defaults`.
    /// - Parameter path: the path to use in the request
    /// - Returns: a `Pumpkin` request instance
    public func path(_ path: String) -> Self {
        self.pathString = path
        return self
    }
    
    /// Set the value of a header for the request.
    /// - Parameters:
    ///   - type: a header type
    ///   - value: value to set for the header
    /// - Returns: a `Pumpkin` request instance
    public func header(_ type: HeaderType, _ value: String) -> Self {
        headers[type.key] = type.value(with: value)
        return self
    }
    
    /// Set the value of a header for the request.
    /// - Parameters:
    ///   - key: a header key
    ///   - value: value to set for the header
    /// - Returns: a `Pumpkin` request instance
    public func header(_ key: String, _ value: String) -> Self {
        headers[key] = value
        return self
    }
    
    /// Ignore a previously set or global header.
    /// - Parameters:
    ///   - key: a header key
    ///   - shouldIgnore: whether the header should be ignored. Defaults to `true`.
    /// - Returns: a `Pumpkin` request instance
    public func ignore(header key: String, _ shouldIgnore: Bool = true) -> Self {
        if shouldIgnore {
            ignoredHeaders.insert(key)
        } else {
            ignoredHeaders.remove(key)
        }
        return self
    }

    /// Ignore a previously set or global header.
    /// - Parameters:
    ///   - type: a header type
    ///   - shouldIgnore: whether the header should be ignored. Defaults to `true`.
    /// - Returns: a `Pumpkin` request instance
    public func ignore(header type: HeaderType, _ shouldIgnore: Bool = true) -> Self {
        return self.ignore(header: type.key, shouldIgnore)
    }
    
    /// Set a query parameter for the request.
    /// - Parameters:
    ///   - key: a query parameter
    ///   - value: value to set for the query parameter
    /// - Returns: a `Pumpkin` request instance
    public func query(_ key: String, _ value: String) -> Self {
        queryParameters[key] = value
        return self
    }
    
    /// Set a body value for the request.
    ///
    /// Adds `Content-Type=application/json` header by default if the header is missing.
    /// - Parameter body: an `Encodable` body to send
    /// - Returns: a `Pumpkin` request instance
    public func body<T: Encodable>(_ body: T) throws -> Self {
        self.body = try JSONEncoder().encode(body)
        if headers["Content-Type"] == nil {
            headers["Content-Type"] = "application/json"
        }
        return self
    }
    
    /// Set a timeout for the request. Defaults to `60`.
    /// - Parameter interval: timeout interval
    /// - Returns: a `Pumpkin` request instance
    public func timeout(_ interval: TimeInterval) -> Self {
        self.timeoutInterval = interval
        return self
    }
    
}

/// Request methods
extension Pumpkin {
    
    /// Perform a `get` request for the current `Pumpkin` request.
    /// - Parameter type: type of `Decodable` object to return.
    /// - Returns: `Decodable` result from the request.
    public func get<T: Decodable>(_ type: T.Type) async throws -> T {
        try await perform(method: .get, type: type)
    }
    
    /// Perform `post` request for the current `Pumpkin` request.
    /// - Parameter type: type of `Decodable` object to return
    /// - Returns: `Decodable` result from the request.
    public func post<T: Decodable>(_ type: T.Type) async throws -> T {
        try await perform(method: .post, type: type)
    }
    
    /// Perform `put` request for the current `Pumpkin` request.
    /// - Parameter type: type of `Decodable` object to return
    /// - Returns: `Decodable` result from the request.
    public func put<T: Decodable>(_ type: T.Type) async throws -> T {
        try await perform(method: .put, type: type)
    }
    
    /// Perform `delete` request for the current `Pumpkin` request.
    /// - Parameter type: type of `Decodable` object to return
    /// - Returns: `Decodable` result from the request.
    public func delete<T: Decodable>(_ type: T.Type) async throws -> T {
        try await perform(method: .delete, type: type)
    }
    
    /// Perform `patch` request for the current `Pumpkin` request.
    /// - Parameter type: type of `Decodable` object to return
    /// - Returns: `Decodable` result from the request.
    public func patch<T: Decodable>(_ type: T.Type) async throws -> T {
        try await perform(method: .patch, type: type)
    }
    
    /// Perform a request for the current `Pumpkin` request.
    /// - Parameters:
    ///   - method: type of method for the request
    ///   - type: type of `Decodable` object to return
    /// - Returns: `Decodable` result from the request.
    public func `do`<T: Decodable>(_ method: HTTPMethod, _ type: T.Type) async throws -> T {
        try await perform(method: method, type: type)
    }
    
}

/// Private methods
extension Pumpkin {
    
    fileprivate func perform<T: Decodable>(method: HTTPMethod, type: T.Type) async throws -> T {
        // Build final URL
        let finalURLString: String
        if let urlString = urlString {
            // Explicit URL overrides everything
            finalURLString = urlString
        } else if let baseURL = await Pumpkin.defaults.getBaseURL() {
            // Use base URL from defaults
            if let path = pathString {
                // Combine base URL with path
                let cleanBase = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
                let cleanPath = path.hasPrefix("/") ? path : "/\(path)"
                finalURLString = cleanBase + cleanPath
            } else {
                finalURLString = baseURL
            }
        } else if pathString != nil {
            // Path without base URL is invalid
            throw PumpkinError.invalidURL
        } else {
            throw PumpkinError.invalidURL
        }
        
        guard var components = URLComponents(string: finalURLString) else {
            throw PumpkinError.invalidURL
        }
        
        if !queryParameters.isEmpty {
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        
        guard let finalURL = components.url else {
            throw PumpkinError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeoutInterval
        
        // Merge headers: defaults first, then instance headers (instance wins)
        // Filter out ignored headers from defaults
        let defaultHeaders = await Pumpkin.defaults.getHeaders()
        let filteredDefaults = defaultHeaders.filter { !ignoredHeaders.contains($0.key) }
        let mergedHeaders = filteredDefaults.merging(headers) { _, instance in instance }
        for (key, value) in mergedHeaders {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw PumpkinError.requestFailed(NSError(domain: "Invalid response", code: -1))
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw PumpkinError.httpError(statusCode: httpResponse.statusCode, data: data)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                throw PumpkinError.decodingError(error)
            }
        } catch let error as PumpkinError {
            throw error
        } catch {
            throw PumpkinError.requestFailed(error)
        }
    }
    
}
