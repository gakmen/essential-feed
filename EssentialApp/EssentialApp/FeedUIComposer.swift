//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 11.07.2023.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public struct FeedUIComposer {
    private init() {}
    
    public static func composeFeedControllerWith (
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    
    ) -> FeedViewController {
        
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        
        let feedController = FeedViewController.makeWith (
            delegate: presentationAdapter,
            title: FeedPresenter.title
        )
        
        presentationAdapter.presenter = FeedPresenter (
            errorView: WeakRefVirtualProxy(feedController),
            loadingView: WeakRefVirtualProxy(feedController),
            feedView: FeedViewAdapter(
                controller: feedController,
                loader: imageLoader)
        )
        
        return feedController
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedLoaderPresentationAdapter, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
