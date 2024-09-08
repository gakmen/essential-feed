//
//  LoadFeedImageDataFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Георгий Акмен on 15.08.2023.
//

import XCTest
import EssentialFeed

class LocalFeedImageDataLoaderTests: XCTestCase {

  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()

    XCTAssertTrue(store.receivedMessages.isEmpty)
  }

  func test_loadImageData_requestsStoredDataForURL() {
    let url = anyURL()
    let (sut, store) = makeSUT()

    _ = try? sut.loadImageData(from: url)

    XCTAssertEqual(store.receivedMessages, [.retrieve(dataFor: url)])
  }

  func test_loadImageData_failsOnStoreError() {
    let (sut, store) = makeSUT()
    let failed = LocalFeedImageDataLoader.LoadError.failed

    expect(sut, toCompleteWith: .failure(failed), when: {
      let retrievalError = anyNSError()
      store.completeRetrieval(with: retrievalError)
    })
  }

  func test_loadImageData_deliversNotFoundErrorOnEmptyStore() {
    let (sut, store) = makeSUT()
    let notFound = LocalFeedImageDataLoader.LoadError.notFound

    expect(sut, toCompleteWith: .failure(notFound), when: {
      store.completeRetrieval(with: nil)
    })
  }

  func test_loadImageData_deliversStoredDataOnFoundData() {
    let (sut, store) = makeSUT()
    let foundData = anyData()

    expect(sut, toCompleteWith: .success(foundData), when: {
      store.completeRetrieval(with: foundData)
    })
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
    toCompleteWith expectedResult: Result<Data, Error>,
    when action: () -> Void,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    action()

    let receivedResult = Result { try sut.loadImageData(from: anyURL()) }

    switch (receivedResult, expectedResult) {
    case let (
      .failure(receivedError as LocalFeedImageDataLoader.LoadError),
      .failure(expectedError as LocalFeedImageDataLoader.LoadError)
    ):
      XCTAssertEqual(receivedError, expectedError, file: file, line: line)
    case let (.success(receivedData), .success(expectedData)):
      XCTAssertEqual(receivedData, expectedData, file: file, line: line)
    default:
      XCTFail("Expexcted \(expectedResult), got \(receivedResult) instead", file: file, line: line)
    }
  }
}
