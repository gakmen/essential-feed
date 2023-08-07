//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 06.08.2023.
//

import XCTest
import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_sendsNoMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.message.isEmpty)
    }
    
    func test_didStartLoadingImageData_showsLoadingAnimationAndHidesImageAndRetryControl() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        
        sut.didStartLoadingImageData(for: feedImage)
        
        XCTAssertEqual(view.message[0].image, nil)
        XCTAssertEqual(view.message[0].isLoading, true)
        XCTAssertEqual(view.message[0].shouldRetry, false)
    }
    
    func test_didFinishLoadingImageData_showsImageHidesLoadingAndRetryControl() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        let image = NSImage(systemSymbolName: "circle", accessibilityDescription: nil)!
        let imageData = image.tiffRepresentation!
        
        sut.didFinishLoadingImageData(with: imageData, for: feedImage)
        
        XCTAssertNotNil(view.message[0].image)
        XCTAssertEqual(view.message[0].isLoading, false)
        XCTAssertEqual(view.message[0].shouldRetry, false)
    }
    
    func test_didFinishLoadingImageData_showsRetryControlAndHidesLoading() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: feedImage)
        
        XCTAssertEqual(view.message[0].image, nil)
        XCTAssertEqual(view.message[0].isLoading, false)
        XCTAssertEqual(view.message[0].shouldRetry, true)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter<ViewSpy, NSImage>, view: ViewSpy) {
        let view = ViewSpy()
        let imageTransformer = { NSImage.init(data: $0) }
        let sut = FeedImagePresenter<FeedImagePresenterTests.ViewSpy, NSImage>(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        typealias Image = NSImage
        
        var message = [FeedImageViewModel<NSImage>]()
        
        func display(_ viewModel: FeedImageViewModel<NSImage>) {
            message.append(viewModel)
        }
        
    }
}
