//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 02.09.2023.
//

import XCTest
import EssentialFeed

protocol FeedImageCache {
    typealias SaveResult = Result<Void, LocalFeedImageDataLoader.SaveError>
    
    func save(image data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}

class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    typealias Result = FeedImageDataLoader.Result
    
    let decoratee: FeedImageDataLoader
    let cache: FeedImageCache
    
    init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.save(image: data, for: url) { _ in }
            }
            completion(result)
        }
        return task
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let imageData = anyData()
        let (sut, _) = makeSUT(result: .success(imageData))
        
        expect(sut, toCompleteWith: .success(imageData))
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, _) = makeSUT(result: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_loadImageData_doesNotDeliverResultAfterCancellingTask() {
        let (sut, loader) = makeSUT(result: .success(anyData()))
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url], "Expected to stop the task after cancel")
    }
    
    func test_loadImageData_cachesImageDataOnLoaderSuccess() {
        let cache = CacheSpy()
        let (sut, _) = makeSUT(result: .success(anyData()), cache: cache)
        
        _ = sut.loadImageData(from: anyURL()) { result in
            if let data = try? result.get() {
                XCTAssertEqual(cache.messages, [.save(data)])
            }
        }
    }
    
    //MARK: - Helpers
    
    private func makeSUT (
        result: FeedImageDataLoader.Result,
        cache: CacheSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImageDataLoader, ImageLoaderStub) {
        
        let loader = ImageLoaderStub(result: result)
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
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
        
        private(set) var cancelledURLs = [URL]()
        private let result: Result
        
        init(result: Result) {
            self.result = result
        }
        
        private struct Task: FeedImageDataLoaderTask {
            var callback: () -> Void
            
            func cancel() {
                callback()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
            completion(result)
            return Task(callback: { [weak self] in self?.cancelledURLs.append(url) })
        }
    }
    
    private class CacheSpy: FeedImageCache {
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(Data)
        }
        
        func save(image data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data))
        }
    }
}
