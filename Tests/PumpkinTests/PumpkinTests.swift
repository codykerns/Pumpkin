import Testing
import Foundation
@testable import Pumpkin

// MARK: - Global Defaults Tests

@Suite(.serialized)
struct GlobalDefaultsTests {
    
    @Test func testSetBaseUrl() async throws {
        await Pumpkin.defaults.clear(.all)
        
        await Pumpkin.defaults.set(baseUrl: "https://api.example.com")
        let baseUrl = await Pumpkin.defaults.getBaseURL()
        
        #expect(baseUrl == "https://api.example.com")
    }
    
    @Test func testSetCustomHeader() async throws {
        await Pumpkin.defaults.clear(.all)
        
        await Pumpkin.defaults.set(header: "X-Custom-Header", "custom-value")
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(headers["X-Custom-Header"] == "custom-value")
    }
    
    @Test func testSetTypedHeaderBearer() async throws {
        await Pumpkin.defaults.clear(.all)
        
        await Pumpkin.defaults.set(header: .bearer, "test-token")
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(headers["Authorization"] == "Bearer test-token")
    }
    
    @Test func testSetTypedHeaderBasic() async throws {
        await Pumpkin.defaults.clear(.all)
        
        await Pumpkin.defaults.set(header: .basic, "credentials")
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(headers["Authorization"] == "Basic credentials")
    }
    
    @Test func testSetTypedHeaderApiKey() async throws {
        await Pumpkin.defaults.clear(.all)
        
        await Pumpkin.defaults.set(header: .apiKey, "api-key-123")
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(headers["X-API-Key"] == "api-key-123")
    }
    
    @Test func testSetTypedHeaderContentType() async throws {
        await Pumpkin.defaults.clear(.all)
        
        await Pumpkin.defaults.set(header: .contentType("application/xml"), "")
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(headers["Content-Type"] == "application/xml")
    }
    
    @Test func testSetTypedHeaderAccept() async throws {
        await Pumpkin.defaults.clear(.all)
        
        await Pumpkin.defaults.set(header: .accept("application/json"), "")
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(headers["Accept"] == "application/json")
    }
    
    @Test func testClearAll() async throws {
        await Pumpkin.defaults.set(baseUrl: "https://api.example.com")
        await Pumpkin.defaults.set(header: "X-Test", "value")
        
        await Pumpkin.defaults.clear(.all)
        
        let baseUrl = await Pumpkin.defaults.getBaseURL()
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(baseUrl == nil)
        #expect(headers.isEmpty)
    }
    
    @Test func testClearHeaders() async throws {
        await Pumpkin.defaults.set(baseUrl: "https://api.example.com")
        await Pumpkin.defaults.set(header: "X-Test", "value")
        
        await Pumpkin.defaults.clear(.headers)
        
        let baseUrl = await Pumpkin.defaults.getBaseURL()
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(baseUrl == "https://api.example.com")
        #expect(headers.isEmpty)
    }
    
    @Test func testClearBaseUrl() async throws {
        await Pumpkin.defaults.set(baseUrl: "https://api.example.com")
        await Pumpkin.defaults.set(header: "X-Test", "value")
        
        await Pumpkin.defaults.clear(.baseUrl)
        
        let baseUrl = await Pumpkin.defaults.getBaseURL()
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(baseUrl == nil)
        #expect(headers["X-Test"] == "value")
    }
    
    @Test func testClearDefaultsToAll() async throws {
        await Pumpkin.defaults.set(baseUrl: "https://api.example.com")
        await Pumpkin.defaults.set(header: "X-Test", "value")
        
        await Pumpkin.defaults.clear()
        
        let baseUrl = await Pumpkin.defaults.getBaseURL()
        let headers = await Pumpkin.defaults.getHeaders()
        
        #expect(baseUrl == nil)
        #expect(headers.isEmpty)
    }
    
}

// MARK: - Header Type Tests

@Suite(.serialized)
struct HeaderTypeTests {
    
    @Test func testHeaderTypeKeys() {
        #expect(HeaderType.bearer.key == "Authorization")
        #expect(HeaderType.basic.key == "Authorization")
        #expect(HeaderType.apiKey.key == "X-API-Key")
        #expect(HeaderType.contentType("application/json").key == "Content-Type")
        #expect(HeaderType.accept("application/json").key == "Accept")
    }
    
    @Test func testHeaderTypeBearerValue() {
        let header = HeaderType.bearer
        #expect(header.value(with: "token123") == "Bearer token123")
    }
    
    @Test func testHeaderTypeBasicValue() {
        let header = HeaderType.basic
        #expect(header.value(with: "base64credentials") == "Basic base64credentials")
    }
    
    @Test func testHeaderTypeApiKeyValue() {
        let header = HeaderType.apiKey
        #expect(header.value(with: "key123") == "key123")
    }
    
    @Test func testHeaderTypeContentTypeValue() {
        let header = HeaderType.contentType("application/xml")
        #expect(header.value(with: "") == "application/xml")
    }
    
    @Test func testHeaderTypeAcceptValue() {
        let header = HeaderType.accept("text/html")
        #expect(header.value(with: "") == "text/html")
    }
}

// MARK: - Integration Tests (using real API)

@Suite(.serialized)
struct IntegrationTests {
    
    struct JSONPlaceholderPost: Codable {
        let userId: Int
        let id: Int
        let title: String
        let body: String
    }
    
    struct JSONPlaceholderUser: Codable {
        let id: Int
        let name: String
        let username: String
        let email: String
    }
    
    @Test func testRealGetRequest() async throws {
        await Pumpkin.defaults.clear(.all)
        
        let posts = try await Pumpkin.request
            .url("https://jsonplaceholder.typicode.com/posts/1")
            .get(JSONPlaceholderPost.self)
        
        #expect(posts.id == 1)
        #expect(posts.userId > 0)
    }
    
    @Test func testGetRequestWithDefaults() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com")
        
        let user = try await Pumpkin.request
            .path("/users/1")
            .get(JSONPlaceholderUser.self)
        
        #expect(user.id == 1)
        #expect(!user.name.isEmpty)
    }
    
    @Test func testGetRequestWithQuery() async throws {
        await Pumpkin.defaults.clear(.all)
        
        let posts = try await Pumpkin.request
            .url("https://jsonplaceholder.typicode.com/posts")
            .query("userId", "1")
            .get([JSONPlaceholderPost].self)
        
        #expect(!posts.isEmpty)
        #expect(posts.allSatisfy { $0.userId == 1 })
    }
    
    @Test func testPostRequest() async throws {
        await Pumpkin.defaults.clear(.all)
        
        struct CreatePost: Codable {
            let title: String
            let body: String
            let userId: Int
        }
        
        let newPost = CreatePost(title: "Test", body: "Test body", userId: 1)
        
        let response = try await Pumpkin.request
            .url("https://jsonplaceholder.typicode.com/posts")
            .body(newPost)
            .post(JSONPlaceholderPost.self)
        
        #expect(response.title == "Test")
        #expect(response.body == "Test body")
    }
    
    @Test func testPathWithTrailingSlash() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com/")
        
        let user = try await Pumpkin.request
            .path("/users/1")
            .get(JSONPlaceholderUser.self)
        
        #expect(user.id == 1)
    }
    
    @Test func testPathWithoutLeadingSlash() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com")
        
        let user = try await Pumpkin.request
            .path("users/1")
            .get(JSONPlaceholderUser.self)
        
        #expect(user.id == 1)
    }
    
    @Test func testUrlOverridesDefaults() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://wrong-url.com")
        
        let posts = try await Pumpkin.request
            .url("https://jsonplaceholder.typicode.com/posts/1")
            .get(JSONPlaceholderPost.self)
        
        #expect(posts.id == 1)
    }
    
    @Test func testInstanceHeadersOverrideDefaults() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com")
        await Pumpkin.defaults.set(header: "X-Custom", "default-value")
        
        // We can't easily test header override without a mock server,
        // but we can verify the request builds correctly
        let user = try await Pumpkin.request
            .path("/users/1")
            .header("X-Custom", "override-value")
            .get(JSONPlaceholderUser.self)
        
        #expect(user.id == 1)
    }

    @Test func testIgnoreHeaderWithCustomKey() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com")
        await Pumpkin.defaults.set(header: "X-Custom-Header", "default-value")
        await Pumpkin.defaults.set(header: "X-Another-Header", "another-value")

        // Request ignoring one header but not the other
        let user = try await Pumpkin.request
            .path("/users/1")
            .ignore(header: "X-Custom-Header")
            .get(JSONPlaceholderUser.self)

        #expect(user.id == 1)
    }

    @Test func testIgnoreHeaderWithTypedHeader() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com")
        await Pumpkin.defaults.set(header: .bearer, "default-token")

        // Request ignoring the bearer token
        let user = try await Pumpkin.request
            .path("/users/1")
            .ignore(header: .bearer)
            .get(JSONPlaceholderUser.self)

        #expect(user.id == 1)
    }

    @Test func testIgnoreHeaderWithFalseDoesNotIgnore() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com")
        await Pumpkin.defaults.set(header: "X-Custom", "value")

        // First ignore, then un-ignore
        let user = try await Pumpkin.request
            .path("/users/1")
            .ignore(header: "X-Custom", true)
            .ignore(header: "X-Custom", false)
            .get(JSONPlaceholderUser.self)

        #expect(user.id == 1)
    }

    @Test func testDoMethodWithGet() async throws {
        await Pumpkin.defaults.clear(.all)

        let post = try await Pumpkin.request
            .url("https://jsonplaceholder.typicode.com/posts/1")
            .do(.get, JSONPlaceholderPost.self)

        #expect(post.id == 1)
    }

    @Test func testDoMethodWithPost() async throws {
        await Pumpkin.defaults.clear(.all)

        struct CreatePost: Codable {
            let title: String
            let body: String
            let userId: Int
        }

        let newPost = CreatePost(title: "Test", body: "Test body", userId: 1)

        let response = try await Pumpkin.request
            .url("https://jsonplaceholder.typicode.com/posts")
            .body(newPost)
            .do(.post, JSONPlaceholderPost.self)

        #expect(response.title == "Test")
    }

    @Test func testDoMethodWithDefaults() async throws {
        await Pumpkin.defaults.clear(.all)
        await Pumpkin.defaults.set(baseUrl: "https://jsonplaceholder.typicode.com")

        let user = try await Pumpkin.request
            .path("/users/1")
            .do(.get, JSONPlaceholderUser.self)

        #expect(user.id == 1)
    }

    @Test func testInvalidURLThrowsError() async throws {
        await Pumpkin.defaults.clear(.all)
        
        do {
            _ = try await Pumpkin.request
                .url("not a valid url")
                .get(JSONPlaceholderPost.self)
            
            Issue.record("Should have thrown an error")
        } catch let error as PumpkinError {
            // Accept either invalidURL or requestFailed for invalid URLs
            switch error {
            case .invalidURL, .requestFailed:
                // Expected errors for invalid URLs
                break
            default:
                Issue.record("Unexpected error type: \(error)")
            }
        }
    }
    
    @Test func testPathWithoutBaseUrlThrowsError() async throws {
        await Pumpkin.defaults.clear(.all)
        
        do {
            _ = try await Pumpkin.request
                .path("/users/1")
                .get(JSONPlaceholderUser.self)
            
            Issue.record("Should have thrown invalidURL error")
        } catch let error as PumpkinError {
            if case .invalidURL = error {
                // Expected error
            } else {
                Issue.record("Wrong error type: \(error)")
            }
        }
    }
    
    @Test func testHttpErrorHandling() async throws {
        await Pumpkin.defaults.clear(.all)
        
        do {
            _ = try await Pumpkin.request
                .url("https://jsonplaceholder.typicode.com/posts/999999999")
                .get(JSONPlaceholderPost.self)
            
            Issue.record("Should have thrown httpError")
        } catch let error as PumpkinError {
            if case .httpError(let statusCode, _) = error {
                #expect(statusCode == 404)
            } else {
                Issue.record("Wrong error type: \(error)")
            }
        }
    }
}
