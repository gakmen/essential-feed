//
//  XCTTestCase+MemoryLeakTrcaking.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 10.03.2023.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, file: file, line: line)
        }
    }
}
