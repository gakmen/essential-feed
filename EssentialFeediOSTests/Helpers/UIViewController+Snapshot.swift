//
//  UIViewController+Snapshot.swift
//  EssentialFeediOSTests
//
//  Created by Георгий Акмен on 12.09.2023.
//

import UIKit

extension UIViewController {
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
    let size: CGSize
    let safeAreaInsets: UIEdgeInsets
    let layoutMargins: UIEdgeInsets
    let traitCollection: UITraitCollection
    
  static func iPhone17(style: UIUserInterfaceStyle, contentSize: UIContentSizeCategory = .medium) -> SnapshotConfiguration {
      return SnapshotConfiguration(
          size: CGSize(width: 393, height: 852),
          safeAreaInsets: UIEdgeInsets(top: 59, left: 0, bottom: 34, right: 0),
          layoutMargins: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16),
          traitCollection: UITraitCollection(traitsFrom: [
              .init(forceTouchCapability: .unavailable),
              .init(layoutDirection: .leftToRight),
              .init(preferredContentSizeCategory: contentSize),
              .init(userInterfaceIdiom: .phone),
              .init(horizontalSizeClass: .compact),
              .init(verticalSizeClass: .regular),
              .init(displayScale: 3),
              .init(displayGamut: .P3),
              .init(userInterfaceStyle: style)
          ]))
  }
}

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone17(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }
    
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds, format: .init(for: traitCollection))
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
