//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 19.05.2023.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNotNil(deletionError, "Ожидаем ошибку при ошибке удаления", file: file, line: line)
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        deleteCache(from: sut)
        
        expect(sut: sut, toRetrieve: .success(.none), file: file, line: line)
    }
}
