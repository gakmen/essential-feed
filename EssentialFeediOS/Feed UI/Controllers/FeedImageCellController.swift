//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Gosha Akmen on 09.07.2023.
//

import UIKit

final class FeedImageCellController {
    private let viewModel: FeedImageViewModel
    
    init(viewModel: FeedImageViewModel) {
        self.viewModel = viewModel
    }
    
    func view() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
        cell.locationContainer.isHidden = viewModel.isLocationHidden
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        
        cell.onRetry = viewModel.loadImageData
        
        cell.feedImageView.image = nil
        cell.feedImageRetryButton.isHidden = true
        
        viewModel.onImageLoad = { [weak cell] image in
            cell?.feedImageView.image = image
        }
        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            cell?.feedImageContainer.isShimmering = isLoading
        }
        viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
            cell?.feedImageRetryButton.isHidden = !shouldRetry
        }
        
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
}
