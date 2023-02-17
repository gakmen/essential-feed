//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 17.02.2023.
//

import Foundation
import XCTest

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let client = HTTPClient()
        
        XCTAssertNil(client.requestedURL)
    }
}
