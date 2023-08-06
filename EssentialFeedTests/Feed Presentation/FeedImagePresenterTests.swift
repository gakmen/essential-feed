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
    
    func didStartLoadingImageData(for model: FeedImage) {
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
}

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_sendsNoMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingImageData_showsLoadingAnimationAndHidesImageAndRetryControl() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        
        sut.didStartLoadingImageData(for: feedImage)
        
        XCTAssertEqual(view.messages[0].image, nil)
        XCTAssertEqual(view.messages[0].isLoading, true)
        XCTAssertEqual(view.messages[0].shouldRetry, false)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, NSImage>, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter<FeedImagePresenterTests.ViewSpy, NSImage>(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        typealias Image = NSImage
        
        var messages = [FeedImageViewModel<NSImage>]()
        
        func display(_ viewModel: FeedImageViewModel<NSImage>) {
            messages.append(viewModel)
        }
        
    }
}
