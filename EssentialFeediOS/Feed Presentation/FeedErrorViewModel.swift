//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 02.08.2023.
//

struct FeedErrorViewModel {
    var message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: .none)
    }
    
    static func error(_ message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}

