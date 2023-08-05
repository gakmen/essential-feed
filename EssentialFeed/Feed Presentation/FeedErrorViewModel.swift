//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 06.08.2023.
//

public struct FeedErrorViewModel {
    public var message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: .none)
    }
    
    static func error(_ message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
