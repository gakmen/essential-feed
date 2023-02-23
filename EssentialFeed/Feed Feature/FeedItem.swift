//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 17.02.2023.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imgeURL: URL
    
}
