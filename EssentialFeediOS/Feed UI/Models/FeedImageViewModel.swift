//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 14.07.2023.
//

import EssentialFeed
import UIKit

final class FeedImageViewModel {
    typealias Observer<T> = (T) -> Void
    
    var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
    
    init(_ imageLoader: FeedImageDataLoader, _ model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    var location: String? { model.location }
    var isLocationHidden: Bool { model.location == nil }
    var description: String? { model.description }
    
    var onImageLoad: Observer<UIImage>?
    var onImageLoadingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadStateChange?(false)
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        let data = try? result.get()
        if let image = data.flatMap(UIImage.init) {
            onImageLoad?(image)
        } else {
            onShouldRetryImageLoadStateChange?(true)
        }
        onImageLoadingStateChange?(false)
    }
    
    func cancelImageDataLoad() {
        task?.cancel()
        task = nil
    }
}
