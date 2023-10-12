//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 18.02.2023.
//

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(client: client, url: url, mapper: FeedItemsMapper.map)
    }
}
