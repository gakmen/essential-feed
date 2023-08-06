//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 06.08.2023.
//

struct FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        location != nil
    }
}

protocol FeedImageView {
    associatedtype Image
    
    func display(_ viewModel: FeedImageViewModel<Image>)
}

class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    
    var view: View
    
    init(view: View) {
        self.view = view
    }
}

import XCTest

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_sendsNoMessagesToView() {
        let view = ViewSpy()
        _ = FeedImagePresenter<FeedImagePresenterTests.ViewSpy, Any>(view: view)
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    //MARK: - Helpers
    
    private class ViewSpy: FeedImageView {
        typealias Image = Any
        
        var messages = [Any]()
        
        func display(_ viewModel: FeedImageViewModel<Any>) {
            
        }
        
    }
}
