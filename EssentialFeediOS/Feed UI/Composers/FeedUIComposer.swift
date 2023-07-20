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
        
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.refreshController = refreshController 
        
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
extension WeakRefVirtualProxy: FeedImageView where T: FeedImageCellController {
    typealias Image = UIImage
    
    func display(_ viewModel: FeedImageViewModel<UIImage>) {
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
            
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage> (
                model: model,
                imageLoader: loader
            )
            
            let cellController = FeedImageCellController(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(cellController), imageTransformer: UIImage.init)
            
            return cellController
        }
    }
}

private final class FeedImageDataLoaderPresentationAdapter <View: FeedImageView, Image>:
    FeedImageCellControllerDelegate where View.Image == Image {
    
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            guard let self else {return}
            switch result {
            case let .success(data):
                self.presenter?.didFinishLoadingImageData(with: data, for: self.model)
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, for: self.model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
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
        
        feedLoader.load { [weak presenter] result in
            switch result {
            case let .success(feed):
                presenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}
