//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Gosha Akmen on 01.03.2023.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        super.tearDown()
        URLProtocolStub.removeStub()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        
        let exp = expectation(description: "Wait for timeout")
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func test_getFromUrl_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError))

        XCTAssertEqual((receivedError as NSError?)?.code, requestError.code)
        XCTAssertEqual((receivedError as NSError?)?.domain, requestError.domain)
    }
    
    func test_getFromUrl_failsOnAllInvalidCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPResponse(), error: nil)))
    }
    
    func test_getFromUrl_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyResponse()
        
        let receivedValues = resultValuesFor((data: data, response: response, error: nil))

        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_getFromUrl_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let emptyData = Data()
        let response = anyResponse()

        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))
        
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultValuesFor (
        _ values : (data: Data?, response: URLResponse?, error: Error?),
        file: StaticString = #filePath,
        line: UInt = #line
        
    ) -> (data: Data, response: HTTPURLResponse)? {
        
        let receivedResult = resultFor(values, file: file, line: line)
        
        switch receivedResult {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Received \(receivedResult) instead of success", file: file, line: line)
            return nil
        }
    }
    
    private func resultErrorFor (
        _ values : (data: Data?, response: URLResponse?, error: Error?)? = nil,
        taskHandler: ((HTTPClientTask) -> Void) = {_ in},
        file: StaticString = #filePath,
        line: UInt = #line
        
    ) -> Error? {
        
        let receivedResult = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch receivedResult {
        case let .failure(error):
            return error
        default:
            XCTFail("Received \(receivedResult) instead of failure", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor (
        _ values : (data: Data?, response: URLResponse?, error: Error?)? = nil,
        taskHandler: ((HTTPClientTask) -> Void) = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
        
    ) -> HTTPClient.Result {
        
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyURL() -> URL {
        return URL(string: "htts://any-url.com")!
    }
    
    private func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func nonHTTPResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func anyResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    private class URLProtocolStub: URLProtocol {
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
            let requestObserver: ((URLRequest) -> Void)?
        }
        
        private static var _stub: Stub?
        private static var stub: Stub? {
            get { queue.sync { _stub } }
            set { queue.sync { _stub = newValue } }
        }
        
        private static let queue = DispatchQueue(label: "URLProtocolStub.queue")
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }
        
        static func observeRequest(observer: @escaping (URLRequest) -> Void) {
            stub = Stub(data: nil, response: nil, error: nil, requestObserver: observer)
        }
        
        static func removeStub() {
            stub = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let stub = URLProtocolStub.stub else { return }
            
            if let data = stub.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            } else {
                client?.urlProtocolDidFinishLoading(self)
            }
            
            stub.requestObserver?(request)
        }
        
        override func stopLoading() {}
    }
}
