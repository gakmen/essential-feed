//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 29.11.2023.
//

import UIKit

public struct CellController {
    let id: AnyHashable
    let delegate: UITableViewDelegate?
    let dataSource: UITableViewDataSource
    let dsPrefetching: UITableViewDataSourcePrefetching?
    
    public init(id: AnyHashable, _ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.id = id
        self.delegate = dataSource
        self.dataSource = dataSource
        self.dsPrefetching = dataSource
    }
    
    public init(id: AnyHashable, _ dataSource: UITableViewDataSource) {
        self.id = id
        self.delegate = nil
        self.dataSource = dataSource
        self.dsPrefetching = nil
    }
}

extension CellController: Equatable {
    public static func == (lhs: CellController, rhs: CellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension CellController: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
