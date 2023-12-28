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
        let expectedURL = URL(string: "http://base-url.com/v1/feed")!
        
        XCTAssertEqual(receivedURL, expectedURL)
    }
}
