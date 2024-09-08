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

    try? sut.save(image: data, for: url)

    XCTAssertEqual(store.receivedMessages, [.insert(data: data, for: url)])
  }

  func test_saveImageData_deliversFailedErrorOnInsertionError() {
    let (sut, store) = makeSUT()
    let error = LocalFeedImageDataLoader.SaveError.failed

    expect(sut, toCompleteWith: .failure(error), when: {
      let insertionError = anyNSError()
      store.completeInsertion(with: insertionError) })
  }

  func test_saveImageData_succeedsOnSuccessfullInsertion() {
    let (sut, store) = makeSUT()

    expect(sut, toCompleteWith: .success(()), when: {
      store.completeInsertion()
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
    toCompleteWith expectedResult: Swift.Result<Void, Error>,
    when action: () -> Void,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    action()
    
    let receivedResult = Result { try sut.save(image: anyData(), for: anyURL())}

    switch (receivedResult, expectedResult) {
    case (.success, .success):
      break
    case (
      .failure(let receivedError as LocalFeedImageDataLoader.SaveError),
      .failure(let expectedError as LocalFeedImageDataLoader.SaveError)
    ):
      XCTAssertEqual(receivedError, expectedError, file: file, line: line)
    default:
      XCTFail("Expexcted \(expectedResult), got \(receivedResult) instead", file: file, line: line)
    }
  }
}
