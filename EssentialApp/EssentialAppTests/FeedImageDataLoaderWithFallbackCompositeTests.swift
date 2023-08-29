//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 28.08.2023.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    
    let primary: FeedImageDataLoader
    let fallback: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadImageData (
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        
        let task = TaskWrapper()
        task.wrapped = primary.loadImageData(from: url) { [weak self] result in
            switch result {
            case let .success(imageData):
                completion(.success(imageData))
            case .failure:
                _ = self?.fallback.loadImageData(from: url, completion: completion)
            }
        }
        return task
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
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
        
        let task = sut.loadImageData(from: anyURL()) { _ in }
        primary.complete(with: .failure(anyNSError()))
        
        XCTAssertFalse(primary.messages.isEmpty, "Expected to start loading with primary loader")
        XCTAssertFalse(fallback.messages.isEmpty, "Expected to start loading with fallback loader")
    }
    
    func test_loadImageData_cancelsPrimaryLoaderTaskOnCancel() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primary.cancelledURLs, [url], "Expected to cancel URL loading from primary loader")
        XCTAssertTrue(fallback.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
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
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    private class imageLoaderSpy: FeedImageDataLoader {
        typealias ImageLoaderSignature = (url: URL, completion: (FeedImageDataLoader.Result) -> Void)
        
        var messages = [ImageLoaderSignature]()
        private(set) var cancelledURLs = [URL]()
        
        init() {
            
        }
        
        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        func complete(with result: FeedImageDataLoader.Result, at index: Int = 0) {
            messages[index].completion(result)
        }
        
        func loadImageData (
            from url: URL,
            completion: @escaping (FeedImageDataLoader.Result) -> Void
        ) -> FeedImageDataLoaderTask {
            
            messages.append((url, completion))
            
            let task = Task(callback: { self.cancelledURLs.append(url) })
            return task
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
