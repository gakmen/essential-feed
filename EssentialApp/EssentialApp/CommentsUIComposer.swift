//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by  Gosha Akmen on 12.12.2023.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public struct CommentsUIComposer {
    
    private init() {}
    
    typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func composeCommentsControllerWith (
        commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>
    ) -> ListViewController {
        
        let presentationAdapter = FeedPresentationAdapter(loader: commentsLoader)
        
        let feedController = ListViewController.makeWith(title: FeedPresenter.title)
        feedController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter (
            errorView: WeakRefVirtualProxy(feedController),
            loadingView: WeakRefVirtualProxy(feedController),
            resourceView: FeedViewAdapter(
                controller: feedController,
                loader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }),
            mapper: FeedPresenter.map
        )
        
        return feedController
    }
}

private extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! ListViewController
        feedController.title = title
        return feedController
    }
}

