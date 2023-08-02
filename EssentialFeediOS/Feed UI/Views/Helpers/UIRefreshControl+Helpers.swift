//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 02.08.2023.
//

import UIKit

extension UIRefreshControl {
    func update(_ isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
