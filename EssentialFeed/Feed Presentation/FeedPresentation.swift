//
//  FeedPresentation.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 06.08.2023.
//

import Foundation

public struct FeedErrorViewModel {
    public var message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: .none)
    }
    
    static func error(_ message: String) -> FeedErrorViewModel {
        FeedErrorViewModel(message: message)
    }
}
public protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

public struct FeedLoadingViewModel {
    public let isLoading: Bool
}
public protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

public struct FeedViewModel {
    public let feed: [FeedImage]
}
public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
    let errorView: FeedErrorView
    let loadingView: FeedLoadingView
    let feedView: FeedView
    
    private var feedLoadingErrorMessage: String {
        return NSLocalizedString (
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter .self),
            comment: "Error message displayed, when we can't load image feed from the server"
        )
    }
    
    public static var title: String {
        return NSLocalizedString (
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for the feed view"
        )
    }
    
    public init(errorView: FeedErrorView, loadingView: FeedLoadingView, feedView: FeedView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with eror: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(.error(feedLoadingErrorMessage))
    }
}
