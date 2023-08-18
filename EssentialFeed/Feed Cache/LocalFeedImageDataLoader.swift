//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 18.08.2023.
//

public final class LocalFeedImageDataLoader: FeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    private class Task: FeedImageDataLoaderTask {
        
        var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataStore.Result) {
            completion? (
                result
                .mapError { _ in Error.failed }
                .flatMap { data in data.map{ .success($0) } ?? .failure(Error.notFound) }
            )
        }
        
        func cancel() {
            completion = nil
        }
    }
    
    public func loadImageData (
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
        
    ) -> FeedImageDataLoaderTask {
        
        let task = Task(completion)
        store.retrieve(dataFor: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result)
        }
        return task
    }
}
