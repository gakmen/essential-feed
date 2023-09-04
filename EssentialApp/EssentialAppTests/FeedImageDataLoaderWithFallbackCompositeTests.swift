//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 28.08.2023.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase, FeedImageDataLoaderTestCase {
    
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
    ) -> (FeedImageDataLoaderWithFallbackComposite, FeedImageDataLoaderSpy, FeedImageDataLoaderSpy) {
        
        let primaryLoader = FeedImageDataLoaderSpy()
        let fallbackLoader = FeedImageDataLoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, primaryLoader, fallbackLoader)
    }
}
