//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 18.08.2023.
//

public final class LocalFeedImageDataLoader {
    
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader {
    public typealias SaveResult = Result<Void, SaveError>
    
    public enum SaveError: Swift.Error {
        case failed
    }
    
    public func save(image data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        store.insert(image: data, for: url) { result in
            completion(result.mapError { _ in SaveError.failed })
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    
    typealias LoadResult = FeedImageDataLoader.Result
    
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private class LoadImageDataTask: FeedImageDataLoaderTask {
        
        var completion: ((LoadResult) -> Void)?
        
        init(_ completion: @escaping (LoadResult) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: LoadResult) {
            completion? (
                result
                .mapError { _ in LoadError.failed }
                .flatMap { data in data.map{ .success($0) } ?? .failure(LoadError.notFound) }
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
        
        let task = LoadImageDataTask(completion)
        store.retrieve(dataFor: url) { [weak self] result in
            guard self != nil else { return }
            task.complete(with: result)
        }
        return task
    }
}
