//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 04.09.2023.
//

public protocol FeedImageDataCache {
    func save(image data: Data, for url: URL) throws
}
