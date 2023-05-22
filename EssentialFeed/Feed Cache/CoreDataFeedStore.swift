//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 22.05.2023.
//

import Foundation

public final class CoreDataFeedStore: FeedStore {
    
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], _ timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
