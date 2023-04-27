//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 25.04.2023.
//

import XCTest
import EssentialFeed

@available(macOS 13.0, *)
class CodableFeedStore {
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.local}
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            self.id = image.id
            self.description = image.description
            self.location = image.location
            self.url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], _ timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

@available(macOS 13.0, *)
final class CodableFeedStoreTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        
        let storeURL: URL = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: "image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    override class func tearDown() {
        super.tearDown()
        
        let storeURL: URL = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: "image-feed.store")
        
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Ждём выгрузки кэша")
        
        sut.retrieve() { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Ожидали пустой результат, вместо этого получили \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Ждём выгрузки кэша")
        
        sut.retrieve() { firstResult in
            sut.retrieve() { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Ожидали, что при попытке дважды выгрузить пустой кэш оба раза получим пустой результат, вместо этого получили \(firstResult) и \(secondResult)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInseringCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        let exp = expectation(description: "Ждём выгрузки кэша")
        
        sut.insert(feed.local, timestamp) { insertionError in
            XCTAssertNil(insertionError, "Ожидали успешную вставку картинок")
            
            sut.retrieve() { retrieveResult in
                switch retrieveResult {
                case let .found(retrievedFeed, retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed.local)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                default:
                    XCTFail("Ожидали результат .found с картинками \(feed) и временем \(timestamp), вместо этого получили \(retrieveResult)")
                }
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    //MARK: Вспомогательные методы
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let url = FileManager
            .default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appending(path: "image-feed.store")
        let sut = CodableFeedStore(storeURL: url)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}
