//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 18.08.2023.
//

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void)
    func insert(image data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}
