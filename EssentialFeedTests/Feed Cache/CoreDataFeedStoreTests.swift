//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 17.05.2023.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {

  func test_retrieve_deliversEmptyOnEmptyCache() {
    makeSUT { sut in
      self.assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
  }

  func test_retrieve_hasNoSideEffectsOnEmptyCache() {
    makeSUT { sut in
      self.assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
  }

  func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
    makeSUT { sut in
      self.assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
  }

  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    makeSUT { sut in
      self.assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
  }

  func test_insert_deliversNoErrorOnEmptyCache() {
    makeSUT { sut in
      self.assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
  }

  func test_insert_deliversNoErrorOnNonEmptyCache() {
    makeSUT { sut in
      self.assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
  }

  func test_insert_overridesPreviouslyInsertedCacheValues() {
    makeSUT { sut in
      self.assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
  }

  func test_delete_deliversNoErrorOnEmptyCache() {
    makeSUT { sut in
      self.assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
  }

  func test_delete_hasNoSideEffectsOnEmptyCache() {
    makeSUT { sut in
      self.assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
  }

  func test_delete_deliversNoErrorOnNonEmptyCache() {
    makeSUT { sut in
      self.assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
  }

  func test_delete_emptiesPreviouslyInsertedCache() {
    makeSUT { sut in
      self.assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
  }

  // - MARK: Helpers

  private func makeSUT(
    _ test: @escaping (CoreDataFeedStore) -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
  ) {
    let storeURL = URL(fileURLWithPath: "/dev/null")
    let sut = try! CoreDataFeedStore(storeURL: storeURL)
    trackForMemoryLeaks(sut, file: file, line: line)

    let exp = expectation(description: "retrieve")
    sut.perform {
      test(sut)
      exp.fulfill()
    }
    wait(for: [exp], timeout: 0.1)
  }

}
