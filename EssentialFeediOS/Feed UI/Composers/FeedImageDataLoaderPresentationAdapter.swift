//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 27.07.2023.
//

import EssentialFeed

final class FeedImageDataLoaderPresentationAdapter <View: FeedImageView, Image>:
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
                if let data {
                    self.presenter?.didFinishLoadingImageData(with: data, for: self.model)
                }
            case let .failure(error):
                self.presenter?.didFinishLoadingImageData(with: error, for: self.model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
