//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 25.02.2023.
//

import Foundation

final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map (_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard
            response.isOK,
            let root = try? JSONDecoder().decode(Root.self, from: data)
        else { throw RemoteFeedLoader.Error.invalidData  }
        
        return root.items
    }
}
