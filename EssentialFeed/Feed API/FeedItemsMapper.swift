//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 25.02.2023.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        var feed: [FeedItem] {
            items.map{ $0.item }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            FeedItem (
                id: id,
                description: description,
                location: location,
                imgeURL: image
            )
        }
    }
    
    static func map (
        _ data: Data,
        from response: HTTPURLResponse
    ) -> RemoteFeedLoader.Result {
        
        guard
            response.statusCode == 200,
            let root = try? JSONDecoder()
                .decode(Root.self, from: data)
        else { return .failure(.invalidData) }
        
        return .success(root.feed)
    }
}
