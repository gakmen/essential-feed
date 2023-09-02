//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 02.09.2023.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    typealias Result = FeedImageDataLoader.Result
    
    let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        _ = decoratee.loadImageData(from: url) { result in
            completion(result)
        }
        return Task()
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let imageData = anyData()
        let loader = ImageLoaderStub(result: .success(imageData))
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        
        expect(sut, toCompleteWith: .success(anyData()))
    }
    
    //MARK: - Helpers
    
    private func expect (
        _ sut: FeedImageDataLoader,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
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
        wait(for: [exp], timeout: 1)
    }
    
    private class ImageLoaderStub: FeedImageDataLoader {
        typealias Result = FeedImageDataLoader.Result
        
        let result: Result
        
        init(result: Result) {
            self.result = result
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {
                
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
            completion(result)
            return Task()
        }
    }
}
