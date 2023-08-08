//
//  FeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Георгий Акмен on 08.08.2023.
//

import XCTest
import EssentialFeed

class RemoteFeedImageDataLoader {
    typealias Result = FeedImageDataLoader.Result
    
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) {
        client.get(from: url) {_ in }
    }
}

class FeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData(from: url) {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData(from: url) {_ in }
        sut.loadImageData(from: url) {_ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    //MARK: - Helpers
    
    private func makeSUT (
            url: URL = URL(string: "https://a-url.com")!,
            file: StaticString = #filePath,
            line: UInt = #line
        ) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
            
            let client = HTTPClientSpy()
            let sut = RemoteFeedImageDataLoader(client: client)
            trackForMemoryLeaks(sut, file: file, line: line)
            trackForMemoryLeaks(client, file: file, line: line)
            return (sut, client)
        }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        var requestedURLs: [URL] {
            messages.map {$0.url}
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete (with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete (
            withStatusCode code: Int,
            data: Data,
            at index: Int = 0
        ){
            let response = HTTPURLResponse (
                url: messages[index].url,
                statusCode: code,
                httpVersion: nil,
                headerFields: nil
            )!
            messages[index].completion(.success((data, response)))
        }
    }
}
