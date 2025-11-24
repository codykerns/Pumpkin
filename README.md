# Pumpkin

[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-lightgrey.svg)](https://swift.org)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A lightweight, declarative HTTP request builder for Swift with async/await support.

## Overview

Pumpkin provides a fluent, type-safe API for building and executing HTTP requests in Swift. It leverages Swift's modern concurrency features and Codable protocol to make network requests simple and elegant.

## Features

- Declarative, chainable API for building requests
- Global configuration for base URLs and default headers
- Selective header ignoring for fine-grained control
- Full async/await support
- Automatic JSON encoding/decoding with Codable
- Type-safe header management with common header types
- Query parameter support
- Comprehensive error handling
- Request timeout configuration
- Support for all standard HTTP methods (GET, POST, PUT, DELETE, PATCH)

## Requirements

- macOS 12.0+ / iOS 15.0+ / tvOS 15.0+ / watchOS 8.0+
- Swift 6.2+

## Installation

### Swift Package Manager

Add Pumpkin to your `Package.swift` file:

```
https://github.com/codykerns/Pumpkin.git
```

Or add it directly in Xcode:

1. File > Add Package Dependencies
2. Enter the repository URL
3. Select the version you want to use

## Quick Start

```swift
import Pumpkin

// Simple GET request
struct User: Codable {
    let id: Int
    let name: String
}

let user = try await Pumpkin.request
    .url("https://api.example.com/users/1")
    .header(.bearer, "your-token")
    .get(User.self)

print(user.name)
```

## Usage

### Global Configuration

Set global defaults for your API to avoid repetition across requests:

```swift
import Pumpkin

// Configure once at app startup
await Pumpkin.defaults.set(baseUrl: "https://api.example.com")
await Pumpkin.defaults.set(header: .bearer, "your-access-token")
await Pumpkin.defaults.set(header: "X-API-Version", "v1")

// Now all requests use these defaults
let user = try await Pumpkin.request
    .path("/users/123")
    .get(User.self)

let posts = try await Pumpkin.request
    .path("/posts")
    .query("limit", "10")
    .get([Post].self)
```

You can override defaults on a per-request basis:

```swift
// Override default headers for a specific request
let data = try await Pumpkin.request
    .path("/admin/users")
    .header(.bearer, "admin-token") // Overrides default token
    .get([User].self)

// Use a completely different URL
let external = try await Pumpkin.request
    .url("https://other-api.com/data") // Ignores base URL
    .get(ExternalData.self)
```

Selectively ignore default headers for specific requests:

```swift
// Ignore specific default headers without overriding all defaults
let data = try await Pumpkin.request
    .path("/public/data")
    .ignore(header: .bearer) // Don't use the default bearer token
    .get(PublicData.self)

// Ignore custom headers
let result = try await Pumpkin.request
    .path("/special")
    .ignore(header: "X-API-Version") // Ignore default API version header
    .get(Result.self)

// Toggle ignore on/off
let user = try await Pumpkin.request
    .path("/users/1")
    .ignore(header: "X-Custom", true) // Ignore it
    .ignore(header: "X-Custom", false) // Actually, don't ignore it
    .get(User.self)
```

Clear defaults when needed:

```swift
await Pumpkin.defaults.clear(.all) // Clear everything
await Pumpkin.defaults.clear(.headers) // Clear only headers
await Pumpkin.defaults.clear(.baseUrl) // Clear only base URL
await Pumpkin.defaults.clear() // Defaults to .all
```

### Basic GET Request

```swift
import Pumpkin

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

// Simple GET request
let user = try await Pumpkin.request
    .url("https://api.example.com/users/123")
    .header(.bearer, "your-access-token")
    .get(User.self)
```

### POST Request with Body

```swift
struct CreateUserRequest: Codable {
    let name: String
    let email: String
}

let newUser = try await Pumpkin.request
    .url("https://api.example.com/users")
    .header(.bearer, "your-access-token")
    .header(.contentType("application/json"), "")
    .body(CreateUserRequest(name: "John Doe", email: "john@example.com"))
    .post(User.self)
```

### Query Parameters

```swift
struct SearchResult: Codable {
    let results: [String]
    let total: Int
}

let results = try await Pumpkin.request
    .url("https://api.example.com/search")
    .query("q", "swift")
    .query("limit", "10")
    .query("offset", "0")
    .get(SearchResult.self)
```

### Custom Headers

```swift
let data = try await Pumpkin.request
    .url("https://api.example.com/data")
    .header("X-API-Key", "your-api-key")
    .header("X-Custom-Header", "custom-value")
    .get(Response.self)
```

### Dynamic HTTP Method

Use the `do` method to specify the HTTP method dynamically:

```swift
// Useful when the method is determined at runtime
let method: HTTPMethod = .get
let user = try await Pumpkin.request
    .url("https://api.example.com/users/123")
    .do(method, User.self)

// Works with all HTTP methods
let posts = try await Pumpkin.request
    .url("https://api.example.com/posts")
    .do(.get, [Post].self)

let created = try await Pumpkin.request
    .url("https://api.example.com/posts")
    .body(newPost)
    .do(.post, Post.self)
```

### Request Timeout

```swift
let data = try await Pumpkin.request
    .url("https://api.example.com/slow-endpoint")
    .timeout(30.0) // 30 seconds
    .get(Response.self)
```

### Complete Example

```swift
struct Todo: Codable {
    let id: Int
    let title: String
    let completed: Bool
}

// Configure defaults at app startup
await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com")
await Pumpkin.defaults.set(header: .accept("application/json"), "")

do {
    let todos = try await Pumpkin.request
        .path("/todos")
        .query("userId", "1")
        .timeout(15.0)
        .get([Todo].self)

    print("Fetched \(todos.count) todos")
} catch let error as PumpkinError {
    switch error {
    case .invalidURL:
        print("Invalid URL provided")
    case .httpError(let statusCode, let data):
        print("HTTP error: \(statusCode)")
    case .decodingError(let error):
        print("Failed to decode response: \(error)")
    case .requestFailed(let error):
        print("Request failed: \(error)")
    case .noData:
        print("No data received")
    }
}
```

## API Reference

### Pumpkin

The main request builder class.

#### Static Properties

- `static var request: Pumpkin` - Create a new request builder instance
- `static let defaults: PumpkinDefaults` - Global configuration for all requests

#### Methods

- `url(_ urlString: String) -> Self` - Set the full request URL (overrides base URL + path)
- `path(_ path: String) -> Self` - Set the path to append to the base URL
- `header(_ type: HeaderType, _ value: String) -> Self` - Add a typed header
- `header(_ key: String, _ value: String) -> Self` - Add a custom header
- `ignore(header key: String, _ shouldIgnore: Bool = true) -> Self` - Ignore a custom default header
- `ignore(header type: HeaderType, _ shouldIgnore: Bool = true) -> Self` - Ignore a typed default header
- `query(_ key: String, _ value: String) -> Self` - Add a query parameter
- `body<T: Encodable>(_ body: T) throws -> Self` - Set the request body
- `timeout(_ interval: TimeInterval) -> Self` - Set request timeout
- `get<T: Decodable>(_ type: T.Type) async throws -> T` - Execute GET request
- `post<T: Decodable>(_ type: T.Type) async throws -> T` - Execute POST request
- `put<T: Decodable>(_ type: T.Type) async throws -> T` - Execute PUT request
- `delete<T: Decodable>(_ type: T.Type) async throws -> T` - Execute DELETE request
- `patch<T: Decodable>(_ type: T.Type) async throws -> T` - Execute PATCH request
- `do<T: Decodable>(_ method: HTTPMethod, _ type: T.Type) async throws -> T` - Execute request with dynamic HTTP method

### HTTPMethod

Enum for HTTP request methods.

- `.get` - GET request
- `.post` - POST request
- `.put` - PUT request
- `.delete` - DELETE request
- `.patch` - PATCH request

### PumpkinDefaults

Global configuration actor for setting default values across all requests.

#### Methods

- `func set(baseUrl: String) async` - Set the default base URL
- `func set(header key: String, _ value: String) async` - Set a default custom header
- `func set(header type: HeaderType, _ value: String) async` - Set a default typed header
- `func clear(_ option: ClearOption = .all) async` - Clear defaults (options: `.all`, `.headers`, `.baseUrl`)

### ClearOption

Enum for specifying what to clear from defaults.

- `.all` - Clear both base URL and headers
- `.headers` - Clear only default headers
- `.baseUrl` - Clear only the default base URL

### HeaderType

Enum for common HTTP header types.

- `.bearer` - Bearer token authentication (Authorization header)
- `.basic` - Basic authentication (Authorization header)
- `.apiKey` - API key (X-API-Key header)
- `.contentType(String)` - Content-Type header
- `.accept(String)` - Accept header

### PumpkinError

Error types that can be thrown during request execution.

- `.invalidURL` - The provided URL is invalid
- `.noData` - No data was returned from the request
- `.decodingError(Error)` - Failed to decode the response
- `.httpError(statusCode: Int, data: Data?)` - HTTP error with status code
- `.requestFailed(Error)` - Underlying network request failed

## Error Handling

Pumpkin provides comprehensive error handling through the `PumpkinError` enum. All request methods are throwing functions, so you can use standard Swift error handling:

```swift
do {
    let user = try await Pumpkin.request
        .url("https://api.example.com/user")
        .get(User.self)
} catch let error as PumpkinError {
    // Handle Pumpkin-specific errors
} catch {
    // Handle other errors
}
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is available under the MIT License.
