//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 02.04.2023.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    
    init (store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedItems()
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
    
    func deleteCachedItems() {
        deleteCachedFeedCallCount += 1
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestCacheDeletion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let items = [uniqueItem(), uniqueItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    //MARK: Helpers
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "", location: "", imgeURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "htts://any-url.com")!
    }
}
