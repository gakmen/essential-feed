//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 28.08.2023.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    private struct Task: FeedImageDataLoaderTask {
        func cancel() {}
    }
    
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
        _ = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case let .success(imageData):
                completion(.success(imageData))
            case .failure:
                _ = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return Task()
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
    
    func test_init_doesNotLoadImageData() {
        let (_, primary, fallback) = makeSUT()
        
        XCTAssertTrue(primary.messages.isEmpty, "Expected no loading with primary loader")
        XCTAssertTrue(fallback.messages.isEmpty, "Expected no loading with fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        
        XCTAssertFalse(primary.messages.isEmpty, "Expected to start loading with primary loader")
        XCTAssertTrue(fallback.messages.isEmpty, "Expected no loading with fallback loader")
    }
    
    func test_loadImageData_loadsFromFallbackLoaderOnPrimaryFailure() {
        let (sut, primary, fallback) = makeSUT()
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        primary.complete(with: .failure(anyNSError()))
        
        XCTAssertFalse(primary.messages.isEmpty, "Expected to start loading with primary loader")
        XCTAssertFalse(fallback.messages.isEmpty, "Expected to start loading with fallback loader")
    }
    
    func test_loadImageData_cancelsPrimaryLoaderTaskOnCancel() {
        
    }
    
    //MARK: - Helpers
    
    private func makeSUT (
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImageDataLoaderWithFallbackComposite, imageLoaderSpy, imageLoaderSpy) {
        
        let primaryLoader = imageLoaderSpy()
        let fallbackLoader = imageLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
    
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
    
    private class imageLoaderSpy: FeedImageDataLoader {
        
        var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        init() {
            
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func complete(with result: FeedImageDataLoader.Result, at index: Int = 0) {
            messages[index].completion(result)
        }
        
        func loadImageData (
            from url: URL,
            completion: @escaping (FeedImageDataLoader.Result) -> Void
        ) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }
    
    private class ImageLoaderStub: FeedImageDataLoader {
        let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImageData (
            from url: URL,
            completion: @escaping (FeedImageDataLoader.Result) -> Void
        ) -> FeedImageDataLoaderTask {
            completion(result)
            return Task()
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
