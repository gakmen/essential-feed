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
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case let .success((data, response)):
                if response.statusCode == 200, !data.isEmpty {
                    break
                } else {
                    completion(.failure(Error.invalidData))
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
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
    
    func test_loadImageData_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = anyNSError()
        
        expect (
            sut,
            toCompleteWith: .failure(clientError),
            when: { client.complete(with: clientError) }
        )
    }
    
    func test_loadImageData_deliversInvalidDataErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        let sampleCodes = [199, 201, 300, 400, 500]
        
        sampleCodes.enumerated().forEach { index, code in
            expect (
                sut,
                toCompleteWith: failure(.invalidData),
                when: { client.complete(withStatusCode: code, data: anyData(), at: index) }
            )
        }
    }
    
    func test_loadImageData_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        let emptyData = Data()
        
        expect (
            sut,
            toCompleteWith: failure(.invalidData),
            when: { client.complete(withStatusCode: 200, data: emptyData) }
        )
    }
    
    //MARK: - Helpers
    
    private func makeSUT (
            url: URL = anyURL(),
            file: StaticString = #filePath,
            line: UInt = #line
        ) -> (sut: RemoteFeedImageDataLoader, client: HTTPClientSpy) {
            
            let client = HTTPClientSpy()
            let sut = RemoteFeedImageDataLoader(client: client)
            trackForMemoryLeaks(sut, file: file, line: line)
            trackForMemoryLeaks(client, file: file, line: line)
            return (sut, client)
        }
    
    private func expect (
        _ sut: RemoteFeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func failure(_ error: RemoteFeedImageDataLoader.Error) -> FeedImageDataLoader.Result {
        .failure(error)
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
