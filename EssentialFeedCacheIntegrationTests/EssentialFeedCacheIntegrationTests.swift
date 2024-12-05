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

  func test_loadFeed_deliversNoItemsOnEmptyCache() {
    let feedLoader = makeFeedLoader()

    expect(feedLoader, toLoad: [])
  }

  func test_loadFeed_deliversItemsSavedOnAnotherInstance() {
    let feedLoaderToPerformSave = makeFeedLoader()
    let feedLoaderToPerformLoad = makeFeedLoader()
    let feed = uniqueImageFeed().models

    save(feed, with: feedLoaderToPerformSave)

    expect(feedLoaderToPerformLoad, toLoad: feed)
  }

  func test_saveFeed_overridesItemsSavedOnAnotherInstance() {
    let feedLoaderToPerformFirstSave = makeFeedLoader()
    let feedLoaderToPerformLastSave = makeFeedLoader()
    let feedLoaderToPerformLoad = makeFeedLoader()
    let firstSavedFeed = uniqueImageFeed().models
    let lastSavedFeed = uniqueImageFeed().models

    save(firstSavedFeed, with: feedLoaderToPerformFirstSave)
    save(lastSavedFeed, with: feedLoaderToPerformLastSave)

    expect(feedLoaderToPerformLoad, toLoad: lastSavedFeed)
  }

  func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
    let feedLoaderToPerformSave = makeFeedLoader()
    let feedLoaderToValidate = makeFeedLoader()
    let savedFeed = uniqueImageFeed().models

    save(savedFeed, with: feedLoaderToPerformSave)
    validateCache(with: feedLoaderToValidate)

    expect(feedLoaderToPerformSave, toLoad: savedFeed)
  }

  func test_validateFeedCache_deletesInvalidCache() {
    let feedLoaderToPerformSave = makeFeedLoader(currentDate: .distantPast)
    let feedLoaderToValidate = makeFeedLoader(currentDate: Date())
    let savedFeed = uniqueImageFeed().models

    save(savedFeed, with: feedLoaderToPerformSave)
    validateCache(with: feedLoaderToValidate)

    expect(feedLoaderToPerformSave, toLoad: [])
  }

  //MARK: - LocalFeedImageDataLoaderTests

  func test_loadImageData_deliversSavedDataOnASeparateInstance() {
    let imageLoaderToPerformSave = makeImageDataLoader()
    let imageLoaderToPerformLoad = makeImageDataLoader()
    let feedLoader = makeFeedLoader()
    let image = uniqueImage()
    let dataToSave = anyData()

    save([image], with: feedLoader)
    save(dataToSave, for: image.url, with: imageLoaderToPerformSave)

    expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
  }

  func test_loadImageData_overridesSavedImageDataOnASeparateInstance() {
    let imageLoaderToPerformFirstSave = makeImageDataLoader()
    let imageLoaderToPerformSecondSave = makeImageDataLoader()
    let imageLoaderToPerformLoad = makeImageDataLoader()

    let feedLoader = makeFeedLoader()
    let image = uniqueImage()
    let firstImageData = Data("first".utf8)
    let lastImageData = Data("last".utf8)

    save([image], with: feedLoader)
    save(firstImageData, for: image.url, with: imageLoaderToPerformFirstSave)
    save(lastImageData, for: image.url, with: imageLoaderToPerformSecondSave)

    expect(imageLoaderToPerformLoad, toLoad: lastImageData, for: image.url)
  }

  //MARK: - Helpers

  private func makeFeedLoader(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL)
    let sut = LocalFeedLoader(store: store, currentDate: { currentDate })
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
    do {
      try sut.save(feed)
        } catch {
          XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
    }
  }

  private func validateCache(with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for validation completion")

    loader.validateCache() { result in
      if case let Result.failure(error) = result {
        XCTFail("Expected successful validation, got error: \(error) instead", file: file, line: line)
      }
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }

  private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
    do {
      let loadedFeed = try sut.load()
      XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
    } catch {
      XCTFail("Expected successful feed result, got \(error) instead", file: file, line: line)
    }
  }

  private func testSpecificStoreURL() -> URL {
    return cachesDirectory().appendingPathExtension("\(type(of: self)).store")
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

  private func makeImageDataLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
    let storeURL = testSpecificStoreURL()
    let store = try! CoreDataFeedStore(storeURL: storeURL)
    let sut = LocalFeedImageDataLoader(store: store)
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  private func save (
    _ data: Data,
    for url: URL,
    with loader: LocalFeedImageDataLoader,
    file: StaticString = #file,
    line: UInt = #line
  ){
    do {
      try loader.save(image: data, for: url)
    } catch {
      XCTFail("Expected to save image data successfully, got error \(error) instead", file: file, line: line)
    }
  }

  private func expect (
    _ loader: LocalFeedImageDataLoader,
    toLoad expectedData: Data,
    for url: URL,
    file: StaticString = #file,
    line: UInt = #line
  ){
    do {
      let loadedData = try loader.loadImageData(from: url)
      XCTAssertEqual(loadedData, expectedData, file: file, line: line)
    } catch {
      XCTFail("Expected successfull image data result, got error \(error) instead", file: file, line: line)
    }
  }
}
