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
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingImageData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        
        sut.didStartLoadingImageData(for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
    }
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfullTransformation() {
        let feedImage = uniqueImage()
        let transformedImage = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: {_ in transformedImage})
        
        sut.didFinishLoadingImageData(with: Data(), for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.image, transformedImage)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
    }
    
    func test_didFinishLoadingImageDataWithError_displaysRetry() {
        let (sut, view) = makeSUT()
        let feedImage = uniqueImage()
        
        sut.didFinishLoadingImageData(with: anyNSError(), for: feedImage)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, feedImage.description)
        XCTAssertEqual(message?.location, feedImage.location)
        XCTAssertEqual(message?.image, nil)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
    }
    
    //MARK: - Helpers
    
    private func makeSUT (
        imageTransformer: @escaping (Data) -> AnyImage? = {_ in nil},
        file: StaticString = #file,
        line: UInt = #line
    ) -> (sut: FeedImagePresenter<ViewSpy, AnyImage>, view: ViewSpy) {
        
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private struct AnyImage: Equatable {}
    
    private class ViewSpy: FeedImageView {
        
        private(set) var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
        
    }
}
