//
//  UIImageView+Animations.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 21.07.2023.
//

import UIKit

extension UIImageView {
    func setImageWithAnimation(_ newImage: UIImage?) {
        image = newImage
        
        guard image != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
