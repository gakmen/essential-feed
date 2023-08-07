//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 27.07.2023.
//

import UIKit
import EssentialFeed

final class FeedViewAdapter: FeedView {
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
