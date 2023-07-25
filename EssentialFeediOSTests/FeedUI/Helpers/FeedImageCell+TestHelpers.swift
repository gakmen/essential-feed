//
//  FeedImageCell+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 25.07.2023.
//

import Foundation
import EssentialFeediOS

extension FeedImageCell {
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    var locationText: String? {
        locationLabel.text
    }
    var descriptionText: String? {
        descriptionLabel.text
    }
    var isShowingImageLoadingIndicator: Bool {
        feedImageContainer.isShimmering
    }
    var isShowingRetryButton: Bool {
        !feedImageRetryButton.isHidden
    }
    var renderedImage: Data? {
        feedImageView.image?.pngData()
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}

