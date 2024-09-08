//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 18.08.2023.
//

public final class LocalFeedImageDataLoader {

  private let store: FeedImageDataStore

  public init(store: FeedImageDataStore) {
    self.store = store
  }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
  public enum SaveError: Error {
    case failed
  }

  public func save(image data: Data, for url: URL) throws {
    do {
      try store.insert(image: data, for: url)
    } catch { throw SaveError.failed }
  }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {

  public typealias LoadResult = FeedImageDataLoader.Result

  public enum LoadError: Error {
    case failed
    case notFound
  }

  private class LoadImageDataTask: FeedImageDataLoaderTask {

    var completion: ((LoadResult) -> Void)?

    init(_ completion: @escaping (LoadResult) -> Void) {
      self.completion = completion
    }

    func complete(with result: LoadResult) {
      completion?(result)
    }

    func cancel() {
      completion = nil
    }
  }

  public func loadImageData (
    from url: URL,
    completion: @escaping (FeedImageDataLoader.Result) -> Void

  ) -> FeedImageDataLoaderTask {

    let task = LoadImageDataTask(completion)
    task.complete(
      with: Swift.Result {
        try store.retrieve(dataFor: url)
      }
        .mapError { _ in LoadError.failed}
        .flatMap { data in
          data.map { .success($0) } ?? .failure(LoadError.notFound)
        }
    )
    return task
  }
}
