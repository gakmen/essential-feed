//
//  ListViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 25.07.2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

extension ListViewController {
    
    //MARK: - Shared
    
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithSpyForiOS17Support()
    }
    
    func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }
    
    func replaceRefreshControlWithSpyForiOS17Support() {
        let spyRefreshControl = UIRefreshControlSpy()
        
        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                spyRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }
        
        refreshControl = spyRefreshControl
    }
    
    private class UIRefreshControlSpy: UIRefreshControl {
        private var _isRefreshing = false
        override var isRefreshing: Bool { _isRefreshing }
        override func beginRefreshing() {
            _isRefreshing = true
        }
        override func endRefreshing() {
            _isRefreshing = false
        }
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    var errorMessage: String? {
        errorView.message
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    func getView(at row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRenderedViews(in: section) > row else { return nil }
        
        let ds = tableView.dataSource
        let cell = ds?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: section))
        return cell
    }
    
    func numberOfRenderedViews(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    //MARK: - Feed
    
    func getFeedImageView(at index: Int) -> UITableViewCell? {
        getView(at: index, section: feedImagesSection)
    }
    
    @discardableResult
    func simulateImageViewVisible(at index: Int) -> FeedImageCell? {
        getView(at: index, section: feedImagesSection) as? FeedImageCell
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        simulateImageViewVisible(at: index)?.renderedImage
    }
    
    @discardableResult
    func simulateFeedImageBecomingVisibleAgain(at row: Int) -> FeedImageCell? {
        let view = simulateImageViewNotVisible(at: row)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, willDisplay: view!, forRowAt: index)
        
        return view
    }
    
    @discardableResult
    func simulateImageViewNotVisible(at index: Int) -> FeedImageCell? {
        let view = simulateImageViewVisible(at: index)
        let delegate = tableView.delegate
        guard let cell = view else { return nil }
        let path = IndexPath(row: index, section: feedImagesSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: path)
        return cell
    }
    
    func simulateImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let index = [IndexPath(row: row, section: feedImagesSection)]
        ds?.tableView(tableView, prefetchRowsAt: index)
    }
    
    func simulateImageViewNotNearVisible(at row: Int) {
        simulateImageViewVisible(at: row)
        let ds = tableView.prefetchDataSource
        let index = [IndexPath(row: row, section: feedImagesSection)]
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: index)
    }
    
    func simulateLoadMoreFeedAction() {
        guard let view = getLoadMoreCell() else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: loadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    func simulateLoadMoreCellTap() {
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: loadMoreSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func numberOfRenderedFeedViews() -> Int {
        numberOfRenderedViews(in: feedImagesSection)
    }
    
    private var feedImagesSection: Int { 0 }
    private var loadMoreSection: Int { 1 }
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImagesSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    var isShowingLoadMoreFeedIndicator: Bool {
        return getLoadMoreCell()?.isLoading == true
    }
    
    private func getLoadMoreCell() -> LoadMoreCell? {
        getView(at: 0, section: loadMoreSection) as? LoadMoreCell
    }
    
    var loadMoreFeedErrorMessage: String? {
        getLoadMoreCell()?.message
    }
    
    //MARK: - Comments
    
    func getCommentsView(at index: Int) -> UITableViewCell? {
        getView(at: index, section: commentsSection)
    }
    
    func numberOfRenderedCommentsViews() -> Int {
        numberOfRenderedViews(in: commentsSection)
    }
    
    func commentMessage(at row: Int) -> String? {
        commentView(at: row)?.messageLabel.text
    }
    
    func commentDate(at row: Int) -> String? {
        commentView(at: row)?.dateLabel.text
    }
    
    func commentUsername(at row: Int) -> String? {
        commentView(at: row)?.usernameLabel.text
    }
    
    private func commentView(at row: Int) -> ImageCommentCell? {
        getView(at: row, section: commentsSection) as? ImageCommentCell
    }
    
    private var commentsSection: Int { 0 }
}
