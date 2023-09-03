//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 02.09.2023.
//

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
