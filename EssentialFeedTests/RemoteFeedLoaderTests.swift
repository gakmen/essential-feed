//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 17.02.2023.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    func load() {
        HTTPClient.shared.get(from: URL(string: "http://a-url.com")!)
    }
}

class HTTPClient {
    static var shared = HTTPClient()

    func get(from url: URL) {}
}

class HTTPClientSpy: HTTPClient {
    override func get(from url: URL) {
        requestedURL = url
    }
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    let client = HTTPClientSpy()
    
    func test_init_doesNotRequestDataFromURL() {
        HTTPClient.shared = client
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        HTTPClient.shared = client
        
        let sut = RemoteFeedLoader()
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
