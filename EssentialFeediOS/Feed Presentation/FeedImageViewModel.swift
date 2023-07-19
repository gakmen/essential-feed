//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 14.07.2023.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}
