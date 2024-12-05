//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 02.04.2023.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {

  func test_init_doesNotStoreMessageUponCreation() {
    let (store, _) = makeSUT()

    XCTAssertEqual(store.receivedMessages, [])
  }

  func test_save_doesNotRequestNewCacheInsertionAfterDeletionError() {
    let (store, sut) = makeSUT()
    let deletionError = anyNSError()
    store.completeDeletion(with: deletionError)

    sut.save(uniqueImageFeed().models) { _ in }

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
  }

  func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfullDeletion() {
    let timestamp = Date()
    let (store, sut) = makeSUT(currentDate: { timestamp })
    let feed = uniqueImageFeed()
    store.completeDeletionSuccessfully()

    sut.save(feed.models) { _ in }

    XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
  }

  func test_save_failsOnDeletionError() {
    let (store , sut) = makeSUT()
    let deletionError = anyNSError()

    expect(sut: sut, toCompleteWith: deletionError, when: {
      store.completeDeletion(with: deletionError)
    })
  }

  func test_save_failsOnInsertionError() {
    let (store, sut) = makeSUT()
    let insertionError = anyNSError()

    expect(sut: sut, toCompleteWith: insertionError, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertion(with: insertionError)
    })
  }

  func test_save_succeedsOnSuccessfullCacheInsertion() {
    let (store, sut) = makeSUT()

    expect(sut: sut, toCompleteWith: nil, when: {
      store.completeDeletionSuccessfully()
      store.completeInsertionSuccessfully()
    })
  }

  //MARK: Helpers

  private func expect (
    sut: LocalFeedLoader,
    toCompleteWith expectedError: NSError?,
    when action: () -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let exp = expectation(description: "Wait for save to complete")
    action()

    var receivedError: Error?
    sut.save([uniqueImage()]) { result in
      if case let Result.failure(error) = result { receivedError = error }
      exp.fulfill()
    }

    wait(for: [exp], timeout: 1.0)
    XCTAssertEqual(receivedError as? NSError, expectedError)
  }

  private func makeSUT (
    currentDate: @escaping () -> Date = Date.init,
    file: StaticString = #filePath,
    line: UInt = #line
  ) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {

    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (store, sut)
  }

  private func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "", location: "", url: anyURL())
  }

  private func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map {
      return LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
    }
    return (models, local)
  }

  private func anyURL() -> URL {
    return URL(string: "htts://any-url.com")!
  }

  private func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
  }
}
