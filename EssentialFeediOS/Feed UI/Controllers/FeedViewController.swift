//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 01.07.2023.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching  {
    
    private var refreshController: FeedRefreshViewController?
    private var imageLoader: FeedImageDataLoader?
    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    
    convenience init (refreshController: FeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        refreshControl = refreshController?.view
        tableView.prefetchDataSource = self
        refreshController?.refresh()
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
        return cellController.view()
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