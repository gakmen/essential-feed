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
    private let imageTransformer: (Data) -> Image?
    
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
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
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTransformer(data)
        else { return didFinishLoadingImageData(with: InvalidImageDataError(), for: model) }
        
        view.display (
            FeedImageViewModel (
                description: model.description,
                location: model.location,
                image: image,
                isLoading: false,
                shouldRetry: false
            )
        )
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display (
            FeedImageViewModel (
                description: model.description,
                location: model.location,
                image: nil,
                isLoading: false,
                shouldRetry: true
            )
        )
    }
}

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
