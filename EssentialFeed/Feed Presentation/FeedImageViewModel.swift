//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 07.08.2023.
//

public struct FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        location != nil
    }
}
