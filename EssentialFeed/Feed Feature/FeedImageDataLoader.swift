//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 08.07.2023.
//

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public protocol FeedImageDataLoaderTask {
    func cancel()
}
