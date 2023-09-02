//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 02.09.2023.
//

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    
     func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
