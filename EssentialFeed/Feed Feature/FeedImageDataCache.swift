//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 04.09.2023.
//

import Foundation

public protocol FeedImageDataCache {
  func save(_ data: Data, for url: URL) throws
}
