//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 20.08.2023.
//

import XCTest
import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {

  func test_retrieveImageData_deliversNotFoundWhenEmpty() {
    let sut = makeSUT()

    expect(sut, toCompleteRetrievalWith: .success(nil), for: anyURL())
  }

  func test_retrieveImageData_deliversNotFoundWhenSoreDataURLDoesNotMatch() {
    let sut = makeSUT()
    let url = URL(string: "http://a-url.com")!
    let nonMatchingURL = URL(string: "http://another-url.com")!

    insert(anyData(), for: url, into: sut)

    expect(sut, toCompleteRetrievalWith: .success(nil), for: nonMatchingURL)
  }

  func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageDataMatchingURL() {
    let sut = makeSUT()
    let storedData = anyData()
    let matchingURL = anyURL()

    insert(storedData, for: matchingURL, into: sut)

    expect(sut, toCompleteRetrievalWith: .success(storedData), for: matchingURL)
  }

  func test_retrieveImageData_deliversLastInsertedValue() {
    let sut = makeSUT()
    let firstStoredData = Data("first".utf8)
    let lastStoredData = Data("last".utf8)

    insert(firstStoredData, for: anyURL(), into: sut)
    insert(lastStoredData, for: anyURL(), into: sut)

    expect(sut, toCompleteRetrievalWith: .success(lastStoredData), for: anyURL())
  }

  //MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
    let storeURL = URL(string: "file:///dev/null")!
    let sut = try! CoreDataFeedStore(storeURL: storeURL)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private func expect (
    _ sut: CoreDataFeedStore,
    toCompleteRetrievalWith expectedResult: FeedImageDataStore.RetrievalResult,
    for url: URL,
    file: StaticString = #file,
    line: UInt = #line
  ) {
    let receivedResult = Result { try sut.retrieve(dataFor: url) }

    switch (receivedResult, expectedResult) {
    case let (.success( receivedData), .success(expectedData)):
      XCTAssertEqual(receivedData, expectedData, file: file, line: line)
    default:
      XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
    }
  }

  private func makeLocalImage(for url: URL) -> LocalFeedImage {
    LocalFeedImage(id: UUID(), description: "description", location: "location", url: url)
  }

  private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
    let image = makeLocalImage(for: url)
    let exp = expectation(description: "Wait for insertion completion")

    sut.insert([image], Date()) { result in
      if case let .failure(error) = result {
        XCTFail("Expected successful \(image) insertion, got error: \(error) instead", file: file, line: line)
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)

    do {
      try sut.insert(image: data, for: url)
    } catch {
      XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
    }
  }
}
