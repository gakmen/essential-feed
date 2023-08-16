//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Георгий Акмен on 15.08.2023.
//

import XCTest

protocol FeedImageDataStore {
    func retrieve(from url: URL, completion: (Data) -> Void)
}

final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL) {
        store.retrieve(from: url) { _ in }
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_loadImageData_requestsStoredDataForURL() {
        let url = anyURL()
        let (sut, store) = makeSUT()
        
        sut.loadImageData(from: url)
        
        XCTAssertEqual(store.requestedURL, url)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        return (sut, store)
    }
    
    private class FeedStoreSpy: FeedImageDataStore {
        
        enum ReceivedMessages {
            case retrieve(URL)
        }
        
        var requestedURL: URL? {
            switch messages[0] {
            case let .retrieve(url):
                return url
            }
        }
        
        var messages = [ReceivedMessages]()
        
        func retrieve(from url: URL, completion: (Data) -> Void) {
            messages.append(.retrieve(url))
        }
    }
}
