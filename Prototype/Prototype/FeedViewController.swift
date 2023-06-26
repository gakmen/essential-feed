//
//  FeedViewController.swift
//  Prototype
//
//  Created by  Gosha Akmen on 23.06.2023.
//

import UIKit

final class FeedViewController: UITableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell")!
    }
}
