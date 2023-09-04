//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by  Gosha Akmen on 04.09.2023.
//

import EssentialFeed

public class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    public typealias Result = FeedImageDataLoader.Result
    
    let decoratee: FeedImageDataLoader
    let cache: FeedImageCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    private class TaskWrapper: FeedImageDataLoaderTask {
        var wrapped: FeedImageDataLoaderTask?
        
        func cancel() {
            wrapped?.cancel()
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = TaskWrapper()
        task.wrapped = decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.save(image: data, for: url) { _ in }
            }
            completion(result)
        }
        return task
    }
}
