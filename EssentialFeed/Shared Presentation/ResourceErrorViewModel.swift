//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 06.08.2023.
//

public struct ResourceErrorViewModel {
    public var message: String?
    
    static var noError: ResourceErrorViewModel {
        ResourceErrorViewModel(message: .none)
    }
    
    static func error(_ message: String) -> ResourceErrorViewModel {
        ResourceErrorViewModel(message: message)
    }
}
