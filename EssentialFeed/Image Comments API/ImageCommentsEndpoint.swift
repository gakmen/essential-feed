//
//  ImageCommentsEndpoint.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 26.12.2023.
//

public enum ImageCommentsEndpoint {
    case get(UUID)
    
    public func url(from base: URL) -> URL {
        switch self {
        case let .get(imageID):
            return base.appendingPathComponent("/v1/image/\(imageID)/comments")
        }
    }
}
