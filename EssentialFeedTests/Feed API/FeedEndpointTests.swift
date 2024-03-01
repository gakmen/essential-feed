//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 28.12.2023.
//

import XCTest
import EssentialFeed

class FeedEndpointTests: XCTestCase {
   
    func test_feed_endpointURLWithLimitQuery() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let receivedURL = FeedEndpoint.get().url(from: baseURL)
        
        XCTAssertEqual(receivedURL.scheme, "http", "scheme")
        XCTAssertEqual(receivedURL.host, "base-url.com", "host")
        XCTAssertEqual(receivedURL.path, "/v1/feed", "path")
        XCTAssertEqual(receivedURL.query?.contains("limit=10"), true, "limit query")
    }
    
    func test_feed_endpointURLWithAfterIdQuery() {
        let baseURL = URL(string: "http://base-url.com")!
        let image = uniqueImage()
        
        let receivedURL = FeedEndpoint.get(after: image).url(from: baseURL)
        
        XCTAssertEqual(receivedURL.scheme, "http", "scheme")
        XCTAssertEqual(receivedURL.host, "base-url.com", "host")
        XCTAssertEqual(receivedURL.path, "/v1/feed", "path")
        XCTAssertEqual(receivedURL.query?.contains("limit=10"), true, "limit query")
        XCTAssertEqual(receivedURL.query?.contains("after_id=\(image.id.uuidString)"), true, "after_id query")
    }
}
