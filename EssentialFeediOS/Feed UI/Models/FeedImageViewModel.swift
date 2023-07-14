//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 14.07.2023.
//

import EssentialFeed
import UIKit

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    
    var task: FeedImageDataLoaderTask?
    private let imageLoader: FeedImageDataLoader
    private let model: FeedImage
    private var imageTransformation: (Data) -> Image?
    
    init(_ imageLoader: FeedImageDataLoader, _ model: FeedImage, _ imageTransformation: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.model = model
        self.imageTransformation = imageTransformation
    }
    
    var location: String? { model.location }
    var isLocationHidden: Bool { model.location == nil }
    var description: String? { model.description }
    
    var onImageLoad: Observer<Image>?
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
        if let image = data.flatMap(imageTransformation) {
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
