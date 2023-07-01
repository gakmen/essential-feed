//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 30.06.2023.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init (loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load() { [weak self] result in
            switch result {
            case .success(_):
                self?.refreshControl?.endRefreshing()
            case .failure(_):
                break
            }
        }
    }
}

final class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let (loader, sut) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0, "Expected no loading request before view is loaded")
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1, "Expected a loading request when view is loaded")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2, "Expected another loading request when user initiates a reload")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3, "Expected yet another loading request when user initiates a reload")
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (loader, sut) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once view is loaded")
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once loader completed loading feed")
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loading indicator once user initiates reloading")
        
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loading indicator once user initiated loading is completed")
    }
    
    // MARK: Helpers
    
    private func makeSUT (
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (loader: LoaderSpy, sut: FeedViewController) {
        
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (loader, sut)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }
    }
}

private extension FeedViewController {
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing == true
    }
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
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
