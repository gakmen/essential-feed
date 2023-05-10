//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 10.05.2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
        let exp = expectation(description: "Ждём загрузки кэша")
        var error: Error?
        
        sut.insert(cache.feed, cache.timestamp) { insertionError in
            error = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return error
    }
    
    func expect (
        sut: FeedStore,
        toRetrieve expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Ждём выгрузки кэша")
        
        sut.retrieve() { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
                
            case let (.found(expectedFeed, expectedTimestamp), .found(retrievedFeed, retrievedTimestamp)):
                XCTAssertEqual(expectedFeed, retrievedFeed, file: file, line: line)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp, file: file, line: line)
                
            default:
                XCTFail("Ожидали результат \(expectedResult), вместо этого получили \(retrievedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect (
        sut: FeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        expect(sut: sut, toRetrieve: expectedResult, file: file, line: line)
        expect(sut: sut, toRetrieve: expectedResult, file: file, line: line)
    }
    
    func deleteCache(from sut: FeedStore) -> Error? {
        let exp = expectation(description: "Ждём окончания удаления")
        var error: Error?
        
        sut.deleteCachedFeed { deletionError in
            error = deletionError
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return error
    }
}
