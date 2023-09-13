//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Георгий Акмен on 13.09.2023.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.main.run(until: Date())
    }
}
