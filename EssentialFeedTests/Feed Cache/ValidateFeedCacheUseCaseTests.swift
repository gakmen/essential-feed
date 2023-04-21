//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 20.04.2023.
//

import XCTest
import EssentialFeed

final class ValidateFeedCacheUseCaseTests: XCTestCase {

    func test_init_doesNotStoreMessageUponCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_validateCache_deletesCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .deleteCachedFeed])
    }
    
    func test_validateCache_doesNotDeleteCacheOnEmptyCache() {
            let (store, sut) = makeSUT()
            
            sut.validateCache()
            
            store.completeRetrievalWithEmptyCache()
            
            XCTAssertEqual(store.receivedMessages, [.retrieve])
        }
    
    func test_validateCache_doesNotDeleteLessThanSevenDaysOldCache() {
            let feed = uniqueImageFeed()
            let fixedCurrentDate = Date()
            let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
            let (store, sut) = makeSUT(currentDate: { fixedCurrentDate })
            
            sut.validateCache()
            
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
            
            XCTAssertFalse(store.receivedMessages.contains(.deleteCachedFeed))
        }

    //MARK: Helpers
    
    private func makeSUT (
        currentDate: @escaping () -> Date = Date.init,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (store, sut)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private func anyURL() -> URL {
        return URL(string: "htts://any-url.com")!
    }
    
    private func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "", location: "", url: anyURL())
    }
    
    private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let local = models.map {
            return LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
        return (models, local)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
