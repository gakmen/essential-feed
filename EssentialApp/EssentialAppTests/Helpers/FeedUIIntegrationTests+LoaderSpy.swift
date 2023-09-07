//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 25.07.2023.
//

import EssentialFeed
import EssentialFeediOS

class LoaderSpy: FeedLoader, FeedImageDataLoader {
    
    //MARK: FeedLoader
    private var feedRequests = [(FeedLoader.Result) -> Void]()
    var loadFeedCallCount: Int { feedRequests.count }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "any error", code: 0)
        feedRequests[index](.failure(error))
    }
    
    //MARK: FeedImageDataLoader
    
    var loadedImageURLs: [URL] {
        imageRequests.map { $0.url }
    }
    private(set) var cancelledImageURLs = [URL]()
    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        var cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy {[weak self] in self?.cancelledImageURLs.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}

