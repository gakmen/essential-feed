//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialAppTests
//
//  Created by Георгий Акмен on 30.08.2023.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks (
        _ instance: AnyObject,
        file: StaticString = #filePath,
        line: UInt = #line
    ){
        addTeardownBlock { [weak instance] in
            XCTAssertNil (
                instance,
                "Instance should have been deallocated. Potential memory leak.",
                file: file,
                line: line
            )
        }
    }
}
