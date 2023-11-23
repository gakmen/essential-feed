//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 06.08.2023.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let feedImage = uniqueImage()
        
        let viewModel = FeedImagePresenter.map(feedImage)
        
        XCTAssertEqual(viewModel.description, feedImage.description)
        XCTAssertEqual(viewModel.location, feedImage.location)
    }
}
