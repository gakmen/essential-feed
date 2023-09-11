//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 01.07.2023.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController:
    UITableViewController,
    UITableViewDataSourcePrefetching,
    FeedLoadingView,
    FeedErrorView
{
    @IBOutlet private(set) public var errorView: ErrorView?
    
    private var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    public var delegate: FeedViewControllerDelegate?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(_ cellControllers: [FeedImageCellController]) {
        tableModel = cellControllers
    }
    
    public func display(_ viewModel: FeedLoadingViewModel) {
        refreshControl?.update(viewModel.isLoading)
    }
    
    public func display(_ viewModel: FeedErrorViewModel) {
        errorView?.message = viewModel.message
    }
    
    public override func tableView (
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return tableModel.count
    }
    
    public override func tableView (
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cellController = getCellController(forRowAt: indexPath)
        return cellController.view(in: tableView)
    }
    
    public override func tableView (
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ){
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView (
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ){
        indexPaths.forEach { indexPath in
            let cellController = getCellController(forRowAt: indexPath)
            cellController.preload()
        }
    }
    
    public func tableView (
        _ tableView: UITableView,
        cancelPrefetchingForRowsAt indexPaths: [IndexPath]
    ){
        indexPaths.forEach(cancelCellControllerLoad)
    }
    
    private func getCellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        getCellController(forRowAt: indexPath).cancelLoad()
    }
}
