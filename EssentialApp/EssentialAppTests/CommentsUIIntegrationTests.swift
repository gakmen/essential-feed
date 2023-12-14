//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by  Gosha Akmen on 12.12.2023.
//

import XCTest
import UIKit
import Combine
import EssentialApp
import EssentialFeed
import EssentialFeediOS

class CommentsUIIntegrationTests: FeedUIIntegrationTests {
    
    func test_commentsView_hasTitle() {
        let (_, sut) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request when view is appearing")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2, "Expected another loading request when user initiates a reload")
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3, "Expected yet another loading request when user initiates a reload")
    }
    
    func test_loadCommentsActions_runsAutomaticallyOnlyOnFirstAppearance() {
        let (loader, sut) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0, "Expected no loading requests before view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected a loading request once view appears")
        
        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCommentsCallCount, 1, "Expected no loading request the second time view appears")
    }

    
    func test_loadingIndicator_isVisibleWhileLoadingComments() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is appearing")
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loader completes successfully")
        
        sut.simulateUserInitiatedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates reloading")
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading completes with error")
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [ImageComment]())
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [ImageComment]())
    }
    
    override func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let comment = makeComment()
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 1)
        assertThat(sut, isRendering: [comment])
    }
    
    override func test_loadFeedCompletion_rendersErrorMessageOnError() {
        let (loader, sut) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertNil(sut.errorMessage)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadFeedError)
    }
    
    override func test_errorView_hidesErrorMessageOnReload() {
        let (loader, sut) = makeSUT()
        sut.simulateAppearance()
        loader.completeCommentsLoadingWithError(at: 0)
        
        sut.simulateUserInitiatedReload()
        
        XCTAssertNil(sut.errorMessage)
    }
    
    override func test_tapOnErrorView_hidesErrorMessage() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual (sut.errorMessage, nil)
        
        sut.simulateAppearance()
        loader.completeCommentsLoadingWithError(at: 0)
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
    
    private func makeComment (
        message: String = "any messsage",
        username: String = "any username"
    ) -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }
    
    private class LoaderSpy {
        
        private var commentsRequests = [PassthroughSubject<[ImageComment], Error>]()
        var loadCommentsCallCount: Int { commentsRequests.count }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            commentsRequests.append(publisher)
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with comments: [ImageComment] = [], at index: Int = 0) {
            commentsRequests[index].send(comments)
        }
        
        func completeCommentsLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            commentsRequests[index].send(completion: .failure(error))
        }
    }
    
    private func assertThat (
        _ sut: ListViewController,
        isRendering comments: [ImageComment],
        file: StaticString = #file,
        line: UInt = #line
    ){
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedCommentsViews() == comments.count else {
            return XCTFail (
                "Expected \(comments.count) comments, got \(sut.numberOfRenderedCommentsViews()) instead.",
                file: file,
                line: line
            )
        }
        
        comments.enumerated().forEach { index, comment in
            assertThat(sut, hasViewConfiguredFor: comment, at: index, file: file, line: line)
        }
        
        executeRunLoopToCleanUpReferences()
    }

    func assertThat (
        _ sut: ListViewController,
        hasViewConfiguredFor comment: ImageComment,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line
    ){
        let view = sut.getView(at: index)
        
        guard let cell = view as? ImageCommentCell else {
            return XCTFail (
                "Expected \(ImageCommentCell.self) instance, got \(String(describing: view)) instead",
                file: file,
                line: line
            )
        }
        
        XCTAssertEqual (
            cell.messageLabel.text,
            comment.message,
            "Expected message text to be \(String(describing: comment.message)) for comment at index \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual (
            cell.usernameLabel.text,
            comment.username,
            "Expected username to be \(String(describing: comment.username)) for comment at index \(index)",
            file: file,
            line: line
        )
    }
    
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}
