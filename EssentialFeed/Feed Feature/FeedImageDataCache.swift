//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 04.09.2023.
//

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(image data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
