//
//  NullStore.swift
//  EssentialApp
//
//  Created by  Gosha Akmen on 17.03.2024.
//

import EssentialFeed

struct NullStore: FeedStore {
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
}

extension NullStore: FeedImageDataStore {
  func retrieve(dataFor url: URL) throws -> Data? { nil }

  func insert(image data: Data, for url: URL) throws {}
}
