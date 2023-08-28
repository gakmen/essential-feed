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
    let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func loadImageData (
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        return primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case let .success(imageData):
                completion(.success(imageData))
            case .failure:
                _ = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_loadImageData_deliversPrimaryImageDataOnPrimarySuccess() {
        let primaryImageData = anyData()
        let fallbackImageData = anyData()
        let sut = makeSUT(primaryResult: .success(primaryImageData), fallbackResult: .success(fallbackImageData))
        
        expect(sut, toCompleteWith: .success(primaryImageData))
    }
    
    func test_loadImageData_deliversFallbackImageDataOnPrimaryFailure() {
        let fallbackImageData = anyData()
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .success(fallbackImageData))
        
        expect(sut, toCompleteWith: .success(fallbackImageData))
    }
    
    func test_loadImageData_failsOnBothPrimaryAndFallbackFailure() {
        let sut = makeSUT(primaryResult: .failure(anyNSError()), fallbackResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    //MARK: - Helpers
    
    private func makeSUT (
        primaryResult: FeedImageDataLoader.Result,
        fallbackResult: FeedImageDataLoader.Result,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FeedImageDataLoaderWithFallbackComposite {
        
        let primaryImageLoader = ImageLoaderStub(result: primaryResult)
        let fallbackImageLoader = ImageLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryImageLoader, fallback: fallbackImageLoader)
        trackForMemoryLeaks(primaryImageLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackImageLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
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
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
}
