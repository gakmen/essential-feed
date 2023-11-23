//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 17.11.2023.
//

import XCTest
import EssentialFeed

class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeyesAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        assertLocalizedKeyAndValueExist(bundle, table)
    }
}
