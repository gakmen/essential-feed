//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 27.07.2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    init(controller: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = loader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            
            let adapter = ImageDataPresentationAdapter( loader: { [imageLoader] in imageLoader(model.url) } )
            
            let cellController = FeedImageCellController (
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter
            )
            
            adapter.presenter = LoadResourcePresenter (
                errorView: WeakRefVirtualProxy(cellController),
                loadingView: WeakRefVirtualProxy(cellController),
                resourceView: WeakRefVirtualProxy(cellController),
                mapper: UIImage.tryMake
            )
            
            return cellController
        })
    }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else { throw InvalidImageData() }
        return image
    }
}
