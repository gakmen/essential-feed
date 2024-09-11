//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 19.08.2023.
//

import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {

  enum Message: Equatable {
    case retrieve(dataFor: URL)
    case insert(data: Data, for: URL)
  }

  private(set) var receivedMessages = [Message]()
  private(set) var insertionResult: Result<Void, Error>?
  private(set) var retrievalResult: Result<Data?, Error>?

  func insert(image data: Data, for url: URL) throws {
    receivedMessages.append(.insert(data: data, for: url))
    try insertionResult?.get()
  }

  func completeInsertion(with error: Error) {
    insertionResult = .failure(error)
  }

  func completeInsertion() {
    insertionResult = .success(())
  }

  func retrieve(dataFor url: URL) throws -> Data? {
    receivedMessages.append(.retrieve(dataFor: url))
    return try retrievalResult?.get()
  }

  func completeRetrieval(with error: Error) {
    retrievalResult = .failure(error)
  }

  func completeRetrieval(with data: Data?, at index: Int = 0) {
    retrievalResult = .success(data)
  }
}
