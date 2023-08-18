//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 18.08.2023.
//

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataFor url: URL, completion: @escaping (Result) -> Void)
}
