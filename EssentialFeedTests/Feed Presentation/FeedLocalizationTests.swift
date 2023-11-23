//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by  Gosha Akmen on 25.07.2023.
//

import XCTest
import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeyesAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        assertLocalizedKeyAndValueExist(bundle, table)
    }
}
