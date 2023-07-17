//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 09.07.2023.
//

import UIKit

protocol FeedRefreshDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private(set) lazy var view: UIRefreshControl = createRefreshView()
    
    private let delegate: FeedRefreshDelegate
    
    init(delegate: FeedRefreshDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func createRefreshView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
