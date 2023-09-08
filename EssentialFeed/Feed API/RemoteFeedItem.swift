//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 08.04.2023.
//

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
