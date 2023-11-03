//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 06.08.2023.
//

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

public final class FeedPresenter {
    let errorView: ResourceErrorView
    let loadingView: ResourceLoadingView
    let feedView: FeedView
    
    private var feedLoadingErrorMessage: String {
        return NSLocalizedString (
            "GENERIC_CONNECTION_ERROR",
            tableName: "Shared",
            bundle: Bundle(for: FeedPresenter.self),
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
    
    public init(errorView: ResourceErrorView, loadingView: ResourceLoadingView, feedView: FeedView) {
        self.errorView = errorView
        self.loadingView = loadingView
        self.feedView = feedView
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with eror: Error) {
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
        errorView.display(.error(feedLoadingErrorMessage))
    }
}
