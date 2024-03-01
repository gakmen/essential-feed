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
    private let selection: (FeedImage) -> Void
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    init (
        controller: ListViewController,
        loader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void
    ){
        self.controller = controller
        self.imageLoader = loader
        self.selection = selection
    }
    
    func display(_ viewModel: Paginated<FeedImage>) {
        let feedSection: [CellController] = viewModel.items.map { model in
            
            let adapter = ImageDataPresentationAdapter( loader: { [imageLoader] in imageLoader(model.url) } )
            
            let view = FeedImageCellController (
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter,
                selection: { [selection] in selection(model) }
            )
            
            adapter.presenter = LoadResourcePresenter (
                errorView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                resourceView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake
            )
            
            return CellController(id: model, view)
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller?.display(feedSection)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)
        
        loadMoreAdapter.presenter = LoadResourcePresenter (
            errorView: WeakRefVirtualProxy(loadMore),
            loadingView: WeakRefVirtualProxy(loadMore),
            resourceView: self
        )
        
        let loadMoreSection = [CellController(id: UUID(), loadMore)]
        
        controller?.display(feedSection, loadMoreSection)
    }
}

extension UIImage {
    struct InvalidImageData: Error {}
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else { throw InvalidImageData() }
        return image
    }
}
