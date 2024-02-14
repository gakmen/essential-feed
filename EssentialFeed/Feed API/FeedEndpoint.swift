//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 28.12.2023.
//

public enum FeedEndpoint {
    case get(after: FeedImage? = nil)
    
    public func url(from base: URL) -> URL {
        switch self {
        case let .get(image):
            var components = URLComponents()
            components.scheme = base.scheme
            components.host = base.host
            components.path = base.path + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10"),
                image.map { URLQueryItem(name: "after_id", value: $0.id.uuidString) }
            ].compactMap { $0 }
            
            return components.url!
        }
    }
}
