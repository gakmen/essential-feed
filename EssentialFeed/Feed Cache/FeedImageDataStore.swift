//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 18.08.2023.
//

public protocol FeedImageDataStore {
  typealias RetrievalResult = Swift.Result<Data?, Error>
  typealias InsertionResult = Swift.Result<Void, Error>

  func retrieve(dataFor url: URL) throws -> Data?
  func insert(image data: Data, for url: URL) throws

  @available(*, deprecated)
  func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void)

  @available(*, deprecated)
  func insert(image data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

public extension FeedImageDataStore {
  func retrieve(dataFor url: URL) throws -> Data? {
    let group = DispatchGroup()
    group.enter()
    var result: RetrievalResult!
    retrieve(dataFor: url) {
      result = $0
      group.leave()
    }
    group.wait()
    return try result.get()
  }

  func insert(image data: Data, for url: URL) throws {
    let group = DispatchGroup()
    group.enter()
    var result: InsertionResult!
    insert(image: data, for: url) {
      result = $0
      group.leave()
    }
    group.wait()
    return try result.get()
  }

  func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void) {}
  func insert(image data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
}
