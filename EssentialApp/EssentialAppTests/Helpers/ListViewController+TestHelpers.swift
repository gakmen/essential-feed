//
//  ListViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 25.07.2023.
//

import UIKit
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
    
    func getView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedViews() > row else { return nil }
        
        let ds = tableView.dataSource
        let cell = ds?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: feedImagesSection))
        return cell
    }
    
    //MARK: - Feed
    
    @discardableResult
    func simulateImageViewVisible(at index: Int) -> FeedImageCell? {
        getView(at: index) as? FeedImageCell
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
    
    func numberOfRenderedFeedViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
    
    //MARK: - Comments
    
    func numberOfRenderedCommentsViews() -> Int {
        tableView.numberOfSections == 0 ? 0 : tableView.numberOfRows(inSection: commentsSection)
    }
    
    private var commentsSection: Int {
        return 0
    }
}
