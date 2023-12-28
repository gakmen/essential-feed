//
//  CommentsViewAdapter.swift
//  EssentialApp
//
//  Created by  Gosha Akmen on 13.12.2023.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(_ viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { comment in
            CellController(id: comment, ImageCommentCellController(model: comment))
        })
    }
}

