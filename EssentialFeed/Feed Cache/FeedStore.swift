//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 05.04.2023.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
  func deleteCachedFeed() throws
  func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
  func retrieve() throws -> CachedFeed?
}
