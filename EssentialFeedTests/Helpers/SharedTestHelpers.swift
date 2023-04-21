//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 21.04.2023.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "htts://any-url.com")!
}
