//
//  FeedImageCache.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 04.09.2023.
//

public protocol FeedImageCache {
    typealias SaveResult = Result<Void, LocalFeedImageDataLoader.SaveError>
    
    func save(image data: Data, for url: URL, completion: @escaping (SaveResult) -> Void)
}
