//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 02.09.2023.
//

public protocol FeedCache {
  func save(_ feed: [FeedImage]) throws
}
