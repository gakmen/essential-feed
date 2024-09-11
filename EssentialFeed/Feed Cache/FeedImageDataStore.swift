//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 18.08.2023.
//

public protocol FeedImageDataStore {
  func retrieve(dataFor url: URL) throws -> Data?
  func insert(image data: Data, for url: URL) throws
}
