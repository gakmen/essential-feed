//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 16.07.2023.
//

import EssentialFeed

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

struct FeedErrorViewModel {
    var message: String?
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: FeedLoadingView
    private let errorView: FeedErrorView
    
    init(feedView: FeedView, loadingView: FeedLoadingView, errorView: FeedErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var title: String {
        return NSLocalizedString (
            "FEED_VIEW_TITLE",
            tableName: "Feed",
            bundle: Bundle(for: FeedViewController.self),
            comment: "Title for the feed view"
        )
    }
    
    var feedLoadingErrorMessage: String {
        return NSLocalizedString (
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: FeedViewController.self),
            comment: "Error message displayed, when we can't load image feed from the server"
        )
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
        errorView.display(FeedErrorViewModel(message: .none))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with eror: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
        errorView.display(FeedErrorViewModel(message: feedLoadingErrorMessage))
    }
}
