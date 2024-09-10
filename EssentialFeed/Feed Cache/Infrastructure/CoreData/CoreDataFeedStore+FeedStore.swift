//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 22.08.2023.
//

extension CoreDataFeedStore: FeedStore {
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    return CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        performAsync { context in
            completion(Result {
                let managedCache = try ManagedCache.createNewUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.getImages(from: feed, in: context)
                try context.save()
            })
        }
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        performAsync { context in
            completion(Result {
                try ManagedCache.deleteCache(in: context)
            })
        }
    }
}
