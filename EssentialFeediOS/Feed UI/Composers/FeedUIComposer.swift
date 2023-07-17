//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 11.07.2023.
//

import UIKit
import EssentialFeed

public struct FeedUIComposer {
    private init() {}
    
    public static func composeFeedControllerWith (feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(delegate: presentationAdapter)
        let feedController = FeedViewController(refreshController: refreshController)
        
        presentationAdapter.presenter = FeedPresenter (
            feedView: FeedViewAdapter(controller: feedController, loader: imageLoader),
            loadingView: WeakRefVirtualProxy(refreshController)
        )
        
        return feedController
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let feedImageViewModel = FeedImageViewModel(loader, model, UIImage.init)
            return FeedImageCellController(viewModel: feedImageViewModel)
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
