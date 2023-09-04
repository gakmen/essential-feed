//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 04.09.2023.
//

import XCTest
import EssentialFeed

protocol FeedImageDataLoaderTestCase: XCTestCase {}

extension FeedImageDataLoaderTestCase {
    func expect (
        _ sut: FeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ){
        let exp = expectation(description: "Wait for image data loading completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected to get \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
}
