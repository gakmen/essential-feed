//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 02.09.2023.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestCase {
    
    func test_init_doesNotStartLoading() {
        let (_, loader) = makeSUT()
        
        XCTAssertTrue(loader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsImageFromLoader() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url])
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let data = anyData()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(data), when: {
            loader.complete(with: .success(data))
        })
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(error), when: {
            loader.complete(with: .failure(error))
        })
    }
    
    func test_loadImageData_cachesImageDataOnLoaderSuccess() {
        let url = anyURL()
        let data = anyData()
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: url) { _ in }
        loader.complete(with: .success(data))
        
        XCTAssertEqual(cache.messages, [.save(data, url)])
    }
    
    func test_loadImageData_doesNotCacheImageDataOnLoaderFailure() {
        let cache = CacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        _ = sut.loadImageData(from: anyURL()) { _ in }
        loader.complete(with: .failure(anyNSError()))
        
        XCTAssertTrue(cache.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private func makeSUT (
        cache: CacheSpy = .init(),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (FeedImageDataLoader, FeedImageDataLoaderSpy) {
        
        let loader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class CacheSpy: FeedImageCache {
        
        private(set) var messages = [Message]()
        
        enum Message: Equatable {
            case save(Data, URL)
        }
        
        func save(image data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(data, url))
        }
    }
}
