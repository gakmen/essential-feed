//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 20.08.2023.
//

import XCTest
import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(nil))
    }
    
    public func insert(image data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
}

class CoreDataFeedImageDataStoreTests: XCTestCase {
    
    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .success(nil), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenSoreDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = URL(string: "http://a-url.com")!
        let nonMatchingURL = URL(string: "http://another-url.com")!
        
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteRetrievalWith: .success(nil), for: nonMatchingURL)
    }
    
    //MARK: - Helpers
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(string: "file:///dev/null")!
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func expect (
        _ sut: CoreDataFeedStore,
        toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult,
        for url: URL,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.retrieve(dataFor: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success( receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeLocalImage(for url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "description", location: "location", url: url)
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let image = makeLocalImage(for: url)
        
        sut.insert([image], Date()) { result in
            switch result {
            case let .failure(error):
                XCTFail("Expected successful feed item insertion, got error: \(error) instead", file: file, line: line)
            case .success(()):
                sut.insert(image: data, for: url) { result in
                    switch result {
                    case let .failure(error):
                        XCTFail("Expected successful image data insertion, got error: \(error) instead", file: file, line: line)
                    default:
                        return
                    }
                }
            }
        }
    }
}
