//
//  FeedImageDataLoaderSpy.swift
//  EssentialAppTests
//
//  Created by Георгий Акмен on 04.09.2023.
//

import EssentialFeed

class FeedImageDataLoaderSpy: FeedImageDataLoader {
    typealias ImageLoaderSignature = (url: URL, completion: (FeedImageDataLoader.Result) -> Void)
    
    private var messages = [ImageLoaderSignature]()
    private(set) var cancelledURLs = [URL]()
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    
    init() {
        
    }
    
    private struct Task: FeedImageDataLoaderTask {
        let callback: () -> Void
        func cancel() { callback() }
    }
    
    func complete(with result: FeedImageDataLoader.Result, at index: Int = 0) {
        messages[index].completion(result)
    }
    
    func loadImageData (
        from url: URL,
        completion: @escaping (FeedImageDataLoader.Result) -> Void
    ) -> FeedImageDataLoaderTask {
        
        messages.append((url, completion))
        
        let task = Task { [weak self] in
            self?.cancelledURLs.append(url)
        }
        return task
    }
}
