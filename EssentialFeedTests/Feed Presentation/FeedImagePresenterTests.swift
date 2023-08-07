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
        let feedImage = uniqueImage()
        let transformedImage = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: {_ in transformedImage})
        
        sut.didFinishLoadingImageData(with: Data(), for: feedImage)
        
        XCTAssertEqual(view.message[0].image, transformedImage)
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
        
        private(set) var message = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            message.append(viewModel)
        }
        
    }
}
