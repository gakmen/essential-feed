//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 27.07.2023.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedImageDataLoaderPresentationAdapter <View: FeedImageView, Image>:
    FeedImageCellControllerDelegate where View.Image == Image {
    
    private let model: FeedImage
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private var cancellable: Cancellable?
    
    init(model: FeedImage, imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    var presenter: FeedImagePresenter<View, Image>?
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        cancellable = imageLoader(model.url).sink(
            receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                    
                case let .failure(error):
                    if let model = self?.model {
                        self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                    }
                }
                
            }, receiveValue: { [weak self] data in
                if let data, let model = self?.model {
                    self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                }
            })
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
    }
}
