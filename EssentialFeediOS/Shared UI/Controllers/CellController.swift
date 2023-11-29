//
//  CellController.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 29.11.2023.
//

import UIKit

public struct CellController {
    let delegate: UITableViewDelegate?
    let dataSource: UITableViewDataSource
    let dsPrefetching: UITableViewDataSourcePrefetching?
    
    public init(_ dataSource: UITableViewDataSource & UITableViewDelegate & UITableViewDataSourcePrefetching) {
        self.delegate = dataSource
        self.dataSource = dataSource
        self.dsPrefetching = dataSource
    }
    
    public init(_ dataSource: UITableViewDataSource) {
        self.delegate = nil
        self.dataSource = dataSource
        self.dsPrefetching = nil
    }
}
