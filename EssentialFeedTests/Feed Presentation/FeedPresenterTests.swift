//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 03.08.2023.
//

import XCTest

class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let view = ViewSpy()
        _ = FeedPresenter(view: view)
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    //MARK: - Helpers
    
    private class ViewSpy {
        var messages = [Any]()
    }
    
}
