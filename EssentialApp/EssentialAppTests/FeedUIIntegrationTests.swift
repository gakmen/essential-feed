//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 30.06.2023.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedView_hasTitle() {
        let (_, sut) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, feedViewTitle)
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request when view is appearing")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request when user initiates a reload")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request when user initiates a reload")
    }
    
    func test_loadFeedActions_runsAutomaticallyOnlyOnFirstAppearance() {
        let (loader, sut) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected no loading request the second time view appears")
    }

    
    func test_loadingIndicator_isVisibleWhileLoadingFeed() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is appearing")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loader completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates reloading")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadFeedCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeedCompletion_rendersErrorMessageOnError() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
    }
    
    func test_errorView_hidesErrorMessageOnReload() {
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoadingWithError(at: 0)
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertNil(sut.errorMessage)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual (sut.errorMessage, nil)
        
        sut.simulateAppearance()
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual (sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual (sut.errorMessage, nil)
    }
    
    // MARK: - Image View Tests
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image url request until views become visible")
        
        sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual (
            loader.loadedImageURLs,
            [image0.url],
            "Expected first image URL request once first view becomes visible"
        )
        
        sut.simulateImageViewVisible(at: 1)
        XCTAssertEqual (
            loader.loadedImageURLs,
            [image0.url, image1.url],
            "Expected second image URL request once second view becomes visible"
        )
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no cancelled image URL request until image is not visible")
        
        sut.simulateImageViewNotVisible(at: 0)
        XCTAssertEqual (
            loader.cancelledImageURLs,
            [image0.url],
            "Expected first image URL request once first view becomes visible"
        )
        
        sut.simulateImageViewNotVisible(at: 1)
        XCTAssertEqual (
            loader.cancelledImageURLs,
            [image0.url, image1.url],
            "Expected second image URL request once second view becomes visible"
        )
    }
    
    func test_feedImageView_reloadsImageURLWhenBecomingVisibleAgain() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        
        sut.simulateFeedImageBecomingVisibleAgain(at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image0.url], "Expected two image URL request after first view becomes visible again")
        
        sut.simulateFeedImageBecomingVisibleAgain(at: 1)
        
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image0.url, image1.url, image1.url], "Expected two new image URL request after second view becomes visible again")
    }

    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        sut.tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateImageViewVisible(at: 0)
        let view1 = sut.simulateImageViewVisible(at: 1)
        XCTAssertEqual (
            view0?.isShowingImageLoadingIndicator,
            true,
            "Expected loading indicator for first view while loading first image"
        )
        XCTAssertEqual (
            view1?.isShowingImageLoadingIndicator,
            true,
            "Expected loading indicator for second view while loading second image"
        )
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual (
            view0?.isShowingImageLoadingIndicator,
            false,
            "Expected no loading indicator for first view once first image loading completes successfully"
        )
        XCTAssertEqual (
            view1?.isShowingImageLoadingIndicator,
            true,
            "Expected no loading indicator state change for second view once first image loading completes successfully"
        )
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual (
            view0?.isShowingImageLoadingIndicator,
            false,
            "Expected no loading indicator state change for first view once second image loading completes with error"
        )
        XCTAssertEqual (
            view1?.isShowingImageLoadingIndicator,
            false,
            "Expected no loading indicator for second view once second image loading completes with error"
        )
    }
    
    func test_feedReload_withSameData_doesNotReloadVisibleCellsImageData() {
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        sut.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844)
        
        let image1 = makeImage(url: URL(string: "first")!)
        let image2 = makeImage(url: URL(string: "second")!)
        
        loader.completeFeedLoading(with: [image1, image2])
        sut.view.enforceLayoutCycle()
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image1.url, image2.url, image2.url])
            
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image1, image2], at: 1)
        sut.view.enforceLayoutCycle()
        XCTAssertEqual(loader.loadedImageURLs, [image1.url, image1.url, image2.url, image2.url])
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateImageViewVisible(at: 0)
        let view1 = sut.simulateImageViewVisible(at: 1)
        
        XCTAssertEqual (
            view0?.renderedImage,
            .none,
            "Expected no image on first view while loading first image"
        )
        XCTAssertEqual (
            view1?.renderedImage,
            .none,
            "Expected no image on second view while loading second image"
        )
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual (
            view0?.renderedImage,
            imageData0,
            "Expected image for first view once image loading completes successfully"
        )
        XCTAssertEqual (
            view1?.renderedImage,
            .none,
            "Expected no image state change for second view once first image loading completes successfully"
        )
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual (
            view0?.renderedImage,
            imageData0,
            "Expected no image state change for first view once second image loading completes successfully"
        )
        XCTAssertEqual (
            view1?.renderedImage,
            imageData1,
            "Expected image for second view once image loading completes successfully"
        )
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = sut.simulateImageViewVisible(at: 0)
        let view1 = sut.simulateImageViewVisible(at: 1)
        XCTAssertEqual (
            view0?.isShowingRetryButton,
            false,
            "Expected no retry action on first view while loading the first image"
        )
        XCTAssertEqual (
            view1?.isShowingRetryButton,
            false,
            "Expected no retry action on second view while loading the second image"
        )
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual (
            view0?.isShowingRetryButton,
            false,
            "Expected no retry action on first view once first image loading completes successfully"
        )
        XCTAssertEqual (
            view1?.isShowingRetryButton,
            false,
            "Expected no retry action state change on second view once first image loading completes successfully"
        )
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual (
            view0?.isShowingRetryButton,
            false,
            "Expected no retry action state change on first view once second image loading completes with error"
        )
        XCTAssertEqual (
            view1?.isShowingRetryButton,
            true,
            "Expected retry action on second view once second image loading completes with error"
        )
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view = sut.simulateImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, false, "Expected no retry button while loading image")
        
        let invalidData = Data("Invalid image data".utf8)
        loader.completeImageLoading(with: invalidData, at: 0)
        XCTAssertEqual(view?.isShowingRetryButton, true, "Expected retry button once image loading completes with invalid data")
        
    }
    
    func test_feedImageViewRetryButton_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://first-url.com")!)
        let image1 = makeImage(url: URL(string: "http://second-url.com")!)
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        
        let view0 = sut.simulateImageViewVisible(at: 0)
        let view1 = sut.simulateImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected two image URL requests for the two visible views")
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected only two image URL requests before retry action")
        
        view0?.simulateRetryAction()
        XCTAssertEqual (
            loader.loadedImageURLs, [image0.url, image1.url, image0.url],
            "Expected three URL requests after retry button was pressed on the first view"
        )
        
        view1?.simulateRetryAction()
        XCTAssertEqual (
            loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url],
            "Expected four URL requests after retry button was pressed on the second view"
        )
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://first-url.com")!)
        let image1 = makeImage(url: URL(string: "http://second-url.com")!)
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no URL requests, until image is near visible")
        
        sut.simulateImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request when first image is near visible")
        
        sut.simulateImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request when second image is near visible")
    }
    
    func test_feedImageView_cancelsImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://first-url.com")!)
        let image1 = makeImage(url: URL(string: "http://second-url.com")!)
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not near visible")
        
        sut.simulateImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first image URL request to be cancelled when the first image is not near visible")
        
        sut.simulateImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected second image URL request to be cancelled when the second image is not near visible")
    }
    
    func test_feedImageView_configuresViewCorrectlyWhenTransitioningFromNearVisibleToVisibleWhileStillPreloadingImage() {
            let (loader, sut) = makeSUT()
            
            sut.simulateAppearance()
            loader.completeFeedLoading(with: [makeImage()])
            
            sut.simulateImageViewNearVisible(at: 0)
            let view0 = sut.simulateImageViewVisible(at: 0)
            
            XCTAssertEqual(view0?.renderedImage, nil, "Expected no rendered image when view becomes visible while still preloading image")
            XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry action when view becomes visible while still preloading image")
            XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator when view becomes visible while still preloading image")
            
            let imageData = UIImage.make(withColor: .red).pngData()!
            loader.completeImageLoading(with: imageData, at: 1)
            
            XCTAssertEqual(view0?.renderedImage, imageData, "Expected rendered image after image preloads successfully")
            XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry action after image preloads successfully")
            XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator after image preloads successfully")
        }

    func test_feedImageView_configuresViewCorrectlyWhenCellBecomingVisibleAgain() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])
        
        let view0 = sut.simulateFeedImageBecomingVisibleAgain(at: 0)
        
        XCTAssertEqual(view0?.renderedImage, nil, "Expected no rendered image when view becomes visible again")
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry action when view becomes visible again")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator when view becomes visible again")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 1)
        
        XCTAssertEqual(view0?.renderedImage, imageData, "Expected rendered image when image loads successfully after view becomes visible again")
        XCTAssertEqual(view0?.isShowingRetryButton, false, "Expected no retry when image loads successfully after view becomes visible again")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator when image loads successfully after view becomes visible again")
    }
    
    func test_feedImageView_showsDataForNewViewRequestAfterPreviousViewIsReused() throws {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let previousView = try XCTUnwrap(sut.simulateImageViewNotVisible(at: 0))
        
        let newView = try XCTUnwrap(sut.simulateImageViewVisible(at: 0))
        previousView.prepareForReuse()
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData, at: 1)
        
        XCTAssertEqual(newView.renderedImage, imageData)
    }
    
    func test_feedImageView_doesNotShowDataFromPreviousRequestWhenCellIsReused() throws {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()])
        
        let view0 = try XCTUnwrap(sut.simulateImageViewVisible(at: 0))
        view0.prepareForReuse()
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        
        XCTAssertEqual(view0.renderedImage, .none, "Expected no image state change for reused view once image loading completes successfully")
    }
    
    func test_feedImageView_doesNotRenderLoadedImageWhenNotVisibleAnymore() {
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])
        
        let cell = sut.simulateImageViewNotVisible(at: 0)
        loader.completeImageLoading(with: anyImageData(), at: 0)
        
        XCTAssertNil(cell?.renderedImage, "Expected no rendered image when an image load finishes after the cell is not visible anymore")
    }
    
    func test_loadImageDataCompletion_dispatchesFromBackgroundToMainThread() {
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()])
        _ = sut.simulateImageViewVisible(at: 0)
        
        let exp = expectation(description: "Wait for background queue")
        DispatchQueue.global().async {
            loader.completeImageLoading(with: self.anyImageData(), at: 0 )
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT (
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (loader: LoaderSpy, sut: ListViewController) {
        
        let loader = LoaderSpy()
        let sut = FeedUIComposer.composeFeedControllerWith(feedLoader: loader.loadPublisher, imageLoader: loader.loadImageDataPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (loader, sut)
    }
    
    private func anyImageData() -> Data {
        UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeImage (
        description: String? = nil,
        location: String? = nil,
        url: URL = URL(filePath: "http://any-url.com")
    ) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
}
