//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 14.08.2023.
//

public class RemoteFeedImageDataLoader: FeedImageDataLoader {
    public typealias Result = FeedImageDataLoader.Result
    
    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(completion: (@escaping (FeedImageDataLoader.Result) -> Void)) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func preventFurtherCompletions() {
            completion = nil
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
    }
    
    @discardableResult
    public func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion: completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.statusCode == 200 && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                }
            )
        }
        return task
    }
}
