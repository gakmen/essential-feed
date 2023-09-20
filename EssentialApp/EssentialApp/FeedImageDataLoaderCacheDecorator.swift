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
    let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            if let data = try? result.get() {
                self?.cache.saveIgnoringResult(image: data, url: url)
            }
            completion(result)
        }
    }
}

extension FeedImageDataCache {
    func saveIgnoringResult(image: Data, url: URL) {
        save(image: image, for: url) { _ in }
    }
}

