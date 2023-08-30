//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 28.08.2023.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let (_, primary, fallback) = makeSUT()
        
        XCTAssertTrue(primary.loadedURLs.isEmpty, "Expected no loading with primary loader")
        XCTAssertTrue(fallback.loadedURLs.isEmpty, "Expected no loading with fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primary.loadedURLs, [url], "Expected to load URLs with primary loader")
        XCTAssertTrue(fallback.loadedURLs.isEmpty, "Expected no loaded URLs with fallback loader")
    }
    
    func test_loadImageData_loadsFromFallbackLoaderOnPrimaryFailure() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        _ = sut.loadImageData(from: url) { _ in }
        primary.complete(with: .failure(anyNSError()))
        
        XCTAssertEqual(primary.loadedURLs, [url], "Expected to load URLs with primary loader")
        XCTAssertEqual(fallback.loadedURLs, [url], "Expected to load URLs with fallback loader")
    }
    
    func test_loadImageData_cancelsPrimaryLoaderTaskOnCancel() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(primary.cancelledURLs, [url], "Expected to cancel URLs loading from primary loader")
        XCTAssertTrue(fallback.cancelledURLs.isEmpty, "Expected no cancelled URLs in the fallback loader")
    }
    
    func test_loadImageData_cancelsFallbackLoaderTaskAfterPrimaryLoaderFailure() {
        let (sut, primary, fallback) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImageData(from: url) { _ in }
        primary.complete(with: .failure(anyNSError()))
        task.cancel()
        
        XCTAssertTrue(primary.cancelledURLs.isEmpty, "Expected no cancelled URLs with primary loader")
        XCTAssertEqual(fallback.cancelledURLs, [url], "Expected to cancel URLs loading from fallback loader")
    }
    
    func test_loadImageData_deliversPrimaryDataOnPrimaryLoaderSuccess() {
        let (sut, primary, _) = makeSUT()
        let primaryData = Data("primary data".utf8)
        
        expect(sut, toCompleteWith: .success(primaryData), when: {
            primary.complete(with: .success(primaryData))
        })
    }
    
    func test_loadImageData_deliversFallbackDataOnFallbackLoaderSuccess() {
        let (sut, primary, fallback) = makeSUT()
        let fallbackData = Data("fallback data".utf8)
        
        expect(sut, toCompleteWith: .success(fallbackData), when: {
            primary.complete(with: .failure(anyNSError()))
            fallback.complete(with: .success(fallbackData))
        })
    }
    
    func test_loadImageData_deliversErrorOnBothPrimaryAndFallbackFailure() {
        let (sut, primary, fallback) = makeSUT()
        let error = NSError(domain: "error", code: 0)
        
        expect(sut, toCompleteWith: .failure(error), when: {
            primary.complete(with: .failure(anyNSError()))
            fallback.complete(with: .failure(anyNSError()))
        })
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
    
    private func trackForMemoryLeaks (
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        addTeardownBlock { [weak instance] in
            XCTAssertNil (
                instance,
                "Instance should have been deallocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
    }
    
    private func expect (
        _ sut: FeedImageDataLoaderWithFallbackComposite,
        toCompleteWith expectedResult: FeedImageDataLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ){
        let exp = expectation(description: "Wait for image data load completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (expectedResult, receivedResult) {
            case let (.success(expectedData), .success(receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1)
    }
    
    private class imageLoaderSpy: FeedImageDataLoader {
        typealias ImageLoaderSignature = (url: URL, completion: (FeedImageDataLoader.Result) -> Void)
        
        private var messages = [ImageLoaderSignature]()
        private(set) var cancelledURLs = [URL]()
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
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
            
            let task = Task { [weak self] in
                self?.cancelledURLs.append(url)
            }
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
