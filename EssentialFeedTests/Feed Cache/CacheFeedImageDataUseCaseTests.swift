//
//  CacheFeedImageDataUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 19.08.2023.
//

import XCTest
import EssentialFeed

class CacheFeedImageDataUseCaseTests: XCTestCase {
    
    func test_saveImageData_requestsImageDataInsertionForURL() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        let data = anyData()
        
        sut.save(image: data, for: url) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
    }
    
    func test_saveImageData_deliversFailedErrorOnInsertionError() {
        let (sut, store) = makeSUT()
        let fail = LocalFeedImageDataLoader.SaveResult.failure(LocalFeedImageDataLoader.SaveError.failed)
        
        expect(sut, toCompleteWith: fail, when: {
            let insertionError = anyNSError()
            store.completeInsertion(with: insertionError) })
    }
    
    func test_saveImageData_succeedsOnSuccessfullInsertion() {
        let (sut, store) = makeSUT()
        let success = LocalFeedImageDataLoader.SaveResult.success(())
        
        expect(sut, toCompleteWith: success, when: {
            store.completeInsertion()
        })
    }
    
    func test_saveImageData_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedImageDataStoreSpy()
        var sut: LocalFeedImageDataLoader? = LocalFeedImageDataLoader(store: store)
        var isResultDelivered: Bool = false
        
        sut?.save(image: anyData(), for: anyURL()) { _ in isResultDelivered = true }
        sut = nil
        store.completeInsertion()
        
        XCTAssertFalse(isResultDelivered, "Expected no received result after instance has been deallocated")
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line)
    -> (sut: LocalFeedImageDataLoader, store: FeedImageDataStoreSpy) {
        
        let store = FeedImageDataStoreSpy()
        let sut = LocalFeedImageDataLoader(store: store)
        return (sut, store)
    }
    
    private func expect (
        _ sut: LocalFeedImageDataLoader,
        toCompleteWith expectedResult: LocalFeedImageDataLoader.SaveResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        
        let exp = expectation(description: "Wait for data retrieval")
        
        sut.save(image: anyData(), for: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
            case let (.failure(receivedError), .failure(expectedError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expexcted \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}
