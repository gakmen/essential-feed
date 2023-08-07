//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 07.08.2023.
//

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
