//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 08.04.2023.
//

import Foundation

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imgeURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imgeURL
    }
}
