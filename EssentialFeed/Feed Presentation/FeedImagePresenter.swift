//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 07.08.2023.
//

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

public final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    var view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display (
            FeedImageViewModel (
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: true,
                shouldRetry: false
            )
        )
    }
    
    private struct InvalidImageDataError: Error {}
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display (
            FeedImageViewModel (
                description: model.description,
                location: model.location,
                image: image,
                isLoading: false,
                shouldRetry: image == nil
            )
        )
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display (
            FeedImageViewModel (
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
    
    public static func map(_ image: FeedImage) -> FeedImageViewModel<Image> {
        FeedImageViewModel (
            description: image.description,
            location: image.location,
            image: nil,
            isLoading: false,
            shouldRetry: false
        )
    }
}
