//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by  Gosha Akmen on 31.05.2023.
//

import XCTest
import EssentialFeed

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        undoStoreSideEffects()
    }
    
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .failure(error):
                XCTFail("Expected successfull result, got \(error) instead")
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [], "Expected empty result")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversItemsSavedOnAnotherInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let savedFeed = uniqueImageFeed().models
        
        let expSave = expectation(description: "Wait for save to complete")
        sutToPerformSave.save(savedFeed) { error in
            XCTAssertNil(error, "Expect saving without errors")
            expSave.fulfill()
        }
        wait(for: [expSave], timeout: 1.0)
        
        let expLoad = expectation(description: "Wait for load to complete")
        sutToPerformLoad.load { result in
            switch result {
                
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, savedFeed)
                
            case let .failure(error):
                XCTFail("Expected success, but received \(error) instead")
            }
            expLoad.fulfill()
        }
        wait(for: [expLoad], timeout: 1.0)
    }
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appending(path: "\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
