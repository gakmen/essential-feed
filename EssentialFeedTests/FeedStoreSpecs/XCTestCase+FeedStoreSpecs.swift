//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 10.05.2023.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversEmptyOnEmptyCache (
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        expect(sut: sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache (
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        expect(sut: sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatRetriveDeliversFoundValuesOnNonEmptyCache (
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toRetrieve: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatRetriveHasNoSideEffectsOnNonEmptyCache (
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp), file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache (
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, file: file, line: line)
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache (
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed().local, Date()), to: sut)
        
        XCTAssertNil(insertionError, file: file, line: line)
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: sut)
        
        expect(sut: sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp), file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache (
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Ожидаем успешное удаление при пустом кэше", file: file, line: line)
    }
    
    func assertThatDeleteDeliversNoErrorOnNonEmptyCache (
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Ожидаем отсутствие ошибки при удалении не пустого кэша", file: file, line: line)
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        insert((uniqueImageFeed().local, Date()), to: sut)
        
        deleteCache(from: sut)
        
        expect(sut: sut, toRetrieve: .empty, file: file, line: line)
    }
    
    func assertThatSideEffectsRunSerially(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, Date()) { _ in
            completedOperationsInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, Date()) { _ in
            completedOperationsInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [op1, op2, op3], "Ожидали, что побочные эффект произойдут по порядку, но порядок нарушился.", file: file, line: line)
    }
    
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
    
    @discardableResult
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
}
