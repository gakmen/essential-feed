//
//  ListViewController.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 01.07.2023.
//

import UIKit
import EssentialFeed

public final class ListViewController:
    UITableViewController,
    UITableViewDataSourcePrefetching,
    ResourceLoadingView,
    ResourceErrorView
{
    private(set) public var errorView = ErrorView()
    
    private lazy var dataSource: UITableViewDiffableDataSource<Int, CellController> = {
        .init(tableView: tableView) { [weak self] tableView, index, controller in
            controller.dataSource.tableView(tableView, cellForRowAt: index)
        }
    }()
    
    private var firstLoad = true
    
    public var onRefresh: (() -> Void)?
    
    var onViewIsAppearingForTheFirstTime: ((ListViewController) -> Void)?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = dataSource
        configureErrorView()
        
        onViewIsAppearingForTheFirstTime = { vc in
            vc.onViewIsAppearingForTheFirstTime = nil
            vc.refresh()
        }
    }
    
    private func configureErrorView() {
        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(errorView)
        
        errorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate ([
            errorView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            errorView.topAnchor.constraint(equalTo: container.topAnchor),
            errorView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        errorView.onHide = { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.sizeTableHeaderToFit()
            self?.tableView.endUpdates()
        }
        
        tableView.tableHeaderView = container
    }
    
    public override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        
        onViewIsAppearingForTheFirstTime?(self)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    @IBAction private func refresh() {
        onRefresh?()
    }
    
    public func display(_ cellControllers: [CellController]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, CellController>()
        snapshot.appendSections([0])
        snapshot.appendItems(cellControllers)
        if firstLoad {
            dataSource.applySnapshotUsingReloadData(snapshot)
        } else {
            dataSource.apply(snapshot)
        }
        firstLoad = false
    }
    
    public func display(_ viewModel: ResourceLoadingViewModel) {
        refreshControl?.update(viewModel.isLoading)
    }
    
    public func display(_ viewModel: ResourceErrorViewModel) {
        errorView.message = viewModel.message
    }
    
    public override func tableView (
        _ tableView: UITableView,
        didEndDisplaying cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ){
        let delegate = getCellController(at: indexPath)?.delegate
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func tableView (
        _ tableView: UITableView,
        prefetchRowsAt indexPaths: [IndexPath]
    ){
        indexPaths.forEach { indexPath in
            let dsPrefetching = getCellController(at: indexPath)?.dsPrefetching
            dsPrefetching?.tableView(tableView, prefetchRowsAt: [indexPath])
        }
    }
    
    public func tableView (
        _ tableView: UITableView,
        cancelPrefetchingForRowsAt indexPaths: [IndexPath]
    ){
        indexPaths.forEach { indexPath in
            let dsPrefetching = getCellController(at: indexPath)?.dsPrefetching
            dsPrefetching?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
        }
    }
    
    private func getCellController(at indexPath: IndexPath) -> CellController? {
        dataSource.itemIdentifier(for: indexPath)
    }
}
