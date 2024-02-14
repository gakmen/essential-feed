//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 28.12.2023.
//

public enum FeedEndpoint {
    case get
    
    public func url(from base: URL) -> URL {
        switch self {
        case .get:
            var components = URLComponents()
            components.scheme = base.scheme
            components.host = base.host
            components.path = base.path + "/v1/feed"
            components.queryItems = [URLQueryItem(name: "limit", value: "10")]
            return components.url!
        }
    }
}
