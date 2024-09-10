//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 22.08.2023.
//

extension CoreDataFeedStore: FeedImageDataStore {

  public func insert(image data: Data, for url: URL) throws {
    try performSync { context in
      Result {
        try ManagedFeedImage.first(with: url, in: context)
          .map { $0.data = data }
          .map { try context.save() }
      }
    }
  }

  public func retrieve(dataFor url: URL) throws -> Data? {
    try performSync { context in
      Result {
        try ManagedFeedImage.data(with: url, in: context)
      }
    }
  }
}
