//
//  FeedViewControllerTests+Localization.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 25.07.2023.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView { func display(_ viewModel: Any) {} }
    
    var feedViewTitle: String { FeedPresenter.title }
    
    var commentsTitle: String { ImageCommentsPresenter.title }
    
    var loadFeedError: String {
        LoadResourcePresenter<Any, DummyView>.loadingErrorMessage
    }
}
