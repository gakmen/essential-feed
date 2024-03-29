//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Георгий Акмен on 30.08.2023.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "htts://any-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}

private class DummyView: ResourceView {
    func display(_ viewModel: Any) {}
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadingErrorMessage
}

var feedViewTitle: String { FeedPresenter.title }

var commentsTitle: String { ImageCommentsPresenter.title }
