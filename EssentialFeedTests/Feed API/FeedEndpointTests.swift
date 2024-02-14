//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 28.12.2023.
//

import XCTest
import EssentialFeed

class FeedEndpointTests: XCTestCase {
   
    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!
        
        let receivedURL = FeedEndpoint.get.url(from: baseURL)
        
        XCTAssertEqual(receivedURL.scheme, "http", "scheme")
        XCTAssertEqual(receivedURL.host, "base-url.com", "host")
        XCTAssertEqual(receivedURL.path, "/v1/feed", "path")
        XCTAssertEqual(receivedURL.query, "limit=10", "query")
    }
}
