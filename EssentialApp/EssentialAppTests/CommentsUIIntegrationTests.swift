//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 12.12.2023.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    override func test_feedView_hasTitle() {
        let (_, sut) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, feedViewTitle)
    }
    
    override func test_loadFeedActions_requestFeedFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request when view is appearing")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 2, "Expected another loading request when user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadFeedCallCount, 3, "Expected yet another loading request when user initiates a reload")
    }
    
    override func test_loadFeedActions_runsAutomaticallyOnlyOnFirstAppearance() {
        let (loader, sut) = makeSUT()
        XCTAssertEqual(loader.loadFeedCallCount, 0, "Expected no loading requests before view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected a loading request once view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadFeedCallCount, 1, "Expected no loading request the second time view appears")
    }

    
    override func test_loadingIndicator_isVisibleWhileLoadingFeed() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is appearing")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loader completes successfully")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates reloading")
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "another location")
        let image2 = makeImage(description: "another description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    override func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnError() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadFeedError)
    }
    
    override func test_errorView_hidesErrorMessageOnReload() {
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoadingWithError(at: 0)
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertNil(sut.errorMessage)
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual (sut.errorMessage, nil)
        
        sut.simulateAppearance()
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual (sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual (sut.errorMessage, nil)
    }
    
    // MARK: - Helpers
    
    private func makeSUT (
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (loader: LoaderSpy, sut: ListViewController) {
        
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.composeCommentsControllerWith(commentsLoader: loader.loadPublisher)
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
}
