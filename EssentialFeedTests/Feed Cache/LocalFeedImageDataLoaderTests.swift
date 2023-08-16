//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Георгий Акмен on 15.08.2023.
//

import XCTest
import EssentialFeed

protocol FeedImageDataStore {
    func retrieve(dataFor url: URL, completion: (Data) -> Void)
}

final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
        
        }
    }
    
    private let store: FeedImageDataStore
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData (
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
        
    ) -> FeedImageDataLoaderTask {
        
        store.retrieve(dataFor: url) { _ in }
        return Task()
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_loadImageData_requestsStoredDataForURL() {
        let url = anyURL()
        let (sut, store) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedImageDataLoader, store: StoreSpy) {
        let store = StoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        return (sut, store)
    }
    
    private class StoreSpy: FeedImageDataStore {
        
        enum Message: Equatable {
            case retrieve(dataFor: URL)
        }
        
        private(set) var receivedMessages = [Message]()
        
        func retrieve(dataFor url: URL, completion: (Data) -> Void) {
            receivedMessages.append(.retrieve(dataFor: url))
        }
    }
}
