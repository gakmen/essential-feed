//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 30.06.2023.
//

import XCTest
import UIKit
import Foundation
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request when view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request when user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request when user initiates a reload")
    }
    
    func test_loadingIndicator_isVisibleWhileLoadingFeed() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loader completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
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
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (loader, sut) = makeSUT()
        sut.loadViewIfNeeded()
        
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
        sut.loadViewIfNeeded()
        
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
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
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
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
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
        
        sut.loadViewIfNeeded()
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
        
        sut.loadViewIfNeeded()
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
        
        sut.loadViewIfNeeded()
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
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1])
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no URL requests, until image is near visible")
        
        sut.simulateImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image URL request when first image is near visible")
        
        sut.simulateImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected second image URL request when second image is near visible")
    }
    
    // MARK: - Helpers
    
    private func makeSUT (
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (loader: LoaderSpy, sut: FeedViewController) {
        
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (loader, sut)
    }
    
    private func makeImage (
        description: String? = nil,
        location: String? = nil,
        url: URL = URL(filePath: "http://any-url.com")
    ) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    
    private func assertThat (
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ){
        XCTAssertEqual (
            sut.numberOfRenderedFeedImageViews(),
            feed.count,
            "Expected number of images to be \(sut.numberOfRenderedFeedImageViews()), got \(feed.count) instead",
            file: file,
            line: line
        )
        
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
    }
    
    private func assertThat (
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line
    ){
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            return XCTFail (
                "Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead",
                file: file,
                line: line
            )
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual (
            cell.isShowingLocation,
            shouldLocationBeVisible,
            "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual (
            cell.locationText,
            image.location,
            "Expected location text to be \(String(describing: image.location)) for image view at index \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual (
            cell.descriptionText,
            image.description,
            "Expected description text to be \(String(describing: image.description)) for image view at index \(index)",
            file: file,
            line: line
        )
    }
    
    //MARK: -
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        //MARK: FeedLoader
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        var loadFeedCallCount: Int { feedRequests.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        //MARK: FeedImageDataLoader
        
        var loadedImageURLs: [URL] {
            imageRequests.map { $0.url }
        }
        private(set) var cancelledImageURLs = [URL]()
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        private struct TaskSpy: FeedImageDataLoaderTask {
            var cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
            func start() {
                
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy {[weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(with imageData: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(imageData))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            let error = NSError(domain: "an error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}


//MARK: -
private extension FeedViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateImageViewVisible(at index: Int) -> FeedImageCell? {
        feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateImageViewNotVisible(at index: Int) {
        let view = simulateImageViewVisible(at: index)
        let delegate = tableView.delegate
        guard let cell = view else { return }
        let path = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: path)
    }
    
    func simulateImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = [IndexPath(row: row, section: feedImagesSection)]
        ds?.tableView(tableView, prefetchRowsAt: index)
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let cell = ds?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: feedImagesSection))
        return cell
    }
}

private extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    var locationText: String? {
        locationLabel.text
    }
    var descriptionText: String? {
        descriptionLabel.text
    }
    var isShowingImageLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
    var isShowingRetryButton: Bool {
        !feedImageRetryButton.isHidden
    }
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

private extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { context in
            color.setFill()
            context.fill(rect)
        }
    }
}
