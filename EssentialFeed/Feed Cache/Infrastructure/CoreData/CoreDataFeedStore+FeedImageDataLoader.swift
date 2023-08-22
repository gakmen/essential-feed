//
//  CoreDataFeedStore+FeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 22.08.2023.
//

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(image data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context)
                    .map { $0.data = data }
                    .map { try context.save() }
            })
        }
    }
    
    public func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        perform { context in
            completion (
                Result {
                    try ManagedFeedImage.first(with: url, in: context)?.data
                }
            )
        }
    }
}
