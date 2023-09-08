//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 25.07.2023.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    var errorMessage: String? {
        errorView?.message
    }
    
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
    
    func renderedFeedImageData(at index: Int) -> Data? {
        simulateImageViewVisible(at: index)?.renderedImage
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
    
    func numberOfRenderedFeedImageViews() -> Int {
        return tableView.numberOfRows(inSection: feedImagesSection)
    }
    
    private var feedImagesSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > row else { return nil }
        
        let ds = tableView.dataSource
        let cell = ds?.tableView(tableView, cellForRowAt: IndexPath(row: row, section: feedImagesSection))
        return cell
    }
}
