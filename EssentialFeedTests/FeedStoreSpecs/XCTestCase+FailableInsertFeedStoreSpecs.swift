//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 19.05.2023.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatInsertDeliversErrorOnInsertionError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        
        XCTAssertNotNil(insertionError, "Ожидали падение с ошибкой при загрузке в кэш", file: file, line: line)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut: sut, toRetrieve: .success(.empty), file: file, line: line)
    }
}
