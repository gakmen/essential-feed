//
//  ImageCommentsEndpointTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 28.12.2023.
//

import XCTest
import EssentialFeed

class ImageCommentsEndpointTests: XCTestCase {
   
    func test_imageComments_endpointURL() {
        let imageID = UUID(uuidString: "2239CBA2-CB35-4392-ADC0-24A37D38E010")!
        let baseURL = URL(string: "http://base-url.com")!
        
        let receivedURL = ImageCommentsEndpoint.get(imageID).url(from: baseURL)
        let expectedURL = URL(string: "http://base-url.com/v1/image/\(imageID)/comments")!
        
        XCTAssertEqual(receivedURL, expectedURL)
    }
}
