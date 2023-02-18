//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 17.02.2023.
//

import Foundation
import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func load() {
        client.get(from: URL(string: "http://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class HTTPClientSpy: HTTPClient {
    func get(from url: URL) {
        requestedURL = url
    }
    var requestedURL: URL?
}

class RemoteFeedLoaderTests: XCTestCase {
    
    let client = HTTPClientSpy()
    
    func test_init_doesNotRequestDataFromURL() {
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let sut = RemoteFeedLoader(client: client)
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
