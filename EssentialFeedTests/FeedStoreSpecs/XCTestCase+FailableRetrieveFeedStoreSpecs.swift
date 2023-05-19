//
//  XCTestCase+FailableRetrieveFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 19.05.2023.
//

import XCTest
import EssentialFeed

extension FailableRetrieveFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatRetrieveDeliversFailureOnRetrievalError(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        expect(sut: sut, toRetrieve: .failure(anyNSError()), file: file, line: line)
    }
    
    func assertThatRetrieveHasNoSideEffectsOnFailure(
        on sut: FeedStore,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        expect(sut: sut, toRetrieveTwice: .failure(anyNSError()), file: file, line: line)
    }
}
