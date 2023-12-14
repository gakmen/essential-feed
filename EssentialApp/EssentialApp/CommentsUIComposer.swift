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
    
    typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func composeCommentsControllerWith (
        commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>
    ) -> ListViewController {
        
        let presentationAdapter = CommentsPresentationAdapter(loader: commentsLoader)
        
        let commentsController = ListViewController.makeWith(title: ImageCommentsPresenter.title)
        commentsController.onRefresh = presentationAdapter.loadResource
        
        presentationAdapter.presenter = LoadResourcePresenter (
            errorView: WeakRefVirtualProxy(commentsController),
            loadingView: WeakRefVirtualProxy(commentsController),
            resourceView: CommentsViewAdapter(controller: commentsController),
            mapper: { ImageCommentsPresenter.map($0) }
        )
        
        return commentsController
    }
}

private extension ListViewController {
    static func makeWith(title: String) -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.title = title
        return controller
    }
}

