//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 28.08.2023.
//

import XCTest
import EssentialFeed

struct ImageDataLoaderTask: FeedImageDataLoaderTask {
    func cancel() {}
}

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    let primary: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
    }
    
    func loadImageData (
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        return primary.loadImageData(from: url, completion: completion)
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadImageData_deliversPrimaryImageDataOnPrimarySuccess() {
        let primaryImageData = anyData()
        let fallbackImageData = anyData()
        let primaryImageLoader = ImageLoaderStub(result: .success(primaryImageData))
        let fallbackImageLoader = ImageLoaderStub(result: .success(fallbackImageData))
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryImageLoader, fallback: fallbackImageLoader)
        
        expect(sut, toCompleteWith: .success(primaryImageData))
    }
    
    //MARK: - Helpers
    
    private func expect (
        _ sut: FeedImageDataLoaderWithFallbackComposite,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ){
        let exp = expectation(description: "Wait for image load completion")
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImageData), .success(expectedImageData)):
                XCTAssertEqual(receivedImageData, expectedImageData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected successful primary image data result, got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    private class ImageLoaderStub: FeedImageDataLoader {
        let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData (
            from url: URL,
            completion: @escaping (FeedImageDataLoader.Result) -> Void
        ) -> FeedImageDataLoaderTask {
            completion(result)
            return ImageDataLoaderTask()
        }
    }
    
    private func anyURL() -> URL {
        return URL(string: "htts://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
}
