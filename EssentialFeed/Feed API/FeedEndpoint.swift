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
            return base.appendingPathComponent("/v1/feed")
        }
    }
}
