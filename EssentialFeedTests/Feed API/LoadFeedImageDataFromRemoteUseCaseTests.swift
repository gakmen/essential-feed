//
//  LoadFeedImageDataFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Георгий Акмен on 08.08.2023.
//

import XCTest
import EssentialFeed

class LoadFeedImageDataFromRemoteUseCaseTests: XCTestCase {
    
    func test_map_throwsInvalidDataErrorOnNon200HTTPResponse() throws {
        let sampleCodes = [199, 201, 300, 400, 500]
        
        try sampleCodes.forEach { code in
            XCTAssertThrowsError (
                try FeedImageDataMapper.map(anyData(), from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let emptyData = Data()
        
        XCTAssertThrowsError (
            try FeedImageDataMapper.map(emptyData, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNonEmptyReceivedDataOn200HTTPResponse() throws {
        let nonEmptyData = Data("non-empty-data".utf8)
        
        let result = try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, nonEmptyData)
    }
}
