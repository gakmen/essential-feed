//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 01.03.2023.
//

import XCTest

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func get(from url: URL) {
        session.dataTask(with: url) { _, _, _ in }
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromUrl_createsDataTaskFromURL() {
        let url: URL = URL(string: "htts://any-url.com")!
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        sut.get(from: url)
        
        XCTAssertEqual(session.receivedURLS, [url])
    }
    
    //MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var receivedURLS = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            receivedURLS.append(url)
            return FakeURLSessionDataTask()
        }
    }
    
    private class FakeURLSessionDataTask: URLSessionDataTask {}
}
