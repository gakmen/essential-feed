//
//  CombineHelpers.swift
//  EssentialApp
//
//  Created by Георгий Акмен on 20.09.2023.
//

import Combine
import Foundation
import EssentialFeed

public extension HTTPClient {
  typealias Publisher = AnyPublisher<(Data, HTTPURLResponse), Error>

  func getPublisher(url: URL) -> Publisher {
    var task: HTTPClientTask?

    return Deferred {
      Future { promise in
        task = self.get(from: url, completion: promise)
      }
    }
    .handleEvents(receiveCancel: { task?.cancel() })
    .eraseToAnyPublisher()
  }
}

public extension FeedImageDataLoader {
  typealias Publisher = AnyPublisher<Data, Error>

  func loadImageDataPublisher(from url: URL) -> Publisher {
    Deferred {
      Future { promise in
        promise(Result { try self.loadImageData(from: url) })
      }
    }
    .eraseToAnyPublisher()
  }
}

public extension Paginated {
  init(items: [Item], loadMorePublisher: (() -> AnyPublisher<Self, Error>)?) {
    self.init(items: items, loadMore: loadMorePublisher.map { publisher in
      return { completion in
        publisher().subscribe(Subscribers.Sink (
          receiveCompletion: { result in
            if case let .failure(error) = result {
              completion(.failure(error))
            }
          },
          receiveValue: { result in
            completion(.success(result))
          })
        )
      }
    })
  }

  var loadMorePublisher: (() -> AnyPublisher<Self, Error>)? {
    guard let loadMore = loadMore else { return nil }

    return {
      Deferred {
        Future(loadMore)
      }.eraseToAnyPublisher()
    }
  }
}

extension Publisher where Output == Data {
  func caching(to cache: FeedImageDataCache, using url: URL) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveOutput: { data in
      cache.saveIgnoringResult(data, for: url)
    }).eraseToAnyPublisher()
  }
}

private extension FeedImageDataCache {
  func saveIgnoringResult(_ data: Data, for url: URL) {
    try? save(data, for: url)
  }
}

public extension LocalFeedLoader {
  typealias Publisher = AnyPublisher<[FeedImage], Error>

  func loadPublisher() -> Publisher {
    Deferred {
      Future { completion in
        completion(Result{ try self.load() })
      }
    }
    .eraseToAnyPublisher()
  }
}


extension FeedCache {
  func saveIgnoringResult(_ feed: [FeedImage]) {
    try? save(feed)
  }
}

extension Publisher where Output == Paginated<FeedImage> {
  func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveOutput: { output in
      cache.saveIgnoringResult(output.items)
    })
    .eraseToAnyPublisher()
  }
}

extension Publisher where Output == [FeedImage] {
  func caching(to cache: FeedCache) -> AnyPublisher<Output, Failure> {
    handleEvents(receiveOutput: { output in
      cache.saveIgnoringResult(output)
    })
    .eraseToAnyPublisher()
  }
}

extension Publisher {
  func fallback(to fallbackPublisher: @escaping () -> AnyPublisher<Output, Failure>) -> AnyPublisher<Output, Failure> {
    self.catch { _ in fallbackPublisher() }.eraseToAnyPublisher()
  }
}

extension Publisher {
  func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
    receive(on: DispatchQueue.immediateWhenOnMainQueueScheduler).eraseToAnyPublisher()
  }
}

extension Publisher {
  func dispatchOnMainThread() -> AnyPublisher<Output, Failure> {
    receive(on: DispatchQueue.immediateWhenOnMainThreadScheduler).eraseToAnyPublisher()
  }
}

extension DispatchQueue {

  static var immediateWhenOnMainQueueScheduler: ImmediateWhenOnMainQueueScheduler {
    ImmediateWhenOnMainQueueScheduler.shared
  }

  struct ImmediateWhenOnMainQueueScheduler: Scheduler {

    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    var now: DispatchQueue.SchedulerTimeType {
      DispatchQueue.main.now
    }
    var minimumTolerance: DispatchQueue.SchedulerTimeType.Stride {
      DispatchQueue.main.minimumTolerance
    }

    static let shared = Self()

    private static let key = DispatchSpecificKey<UInt8>()
    private static let value = UInt8.max

    private init() {
      DispatchQueue.main.setSpecific(key: Self.key, value: Self.value)
    }

    private func isMainQueue() -> Bool {
      DispatchQueue.getSpecific(key: Self.key) == Self.value
    }

    func schedule(options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
      guard isMainQueue() else {
        return DispatchQueue.main.schedule(options: options, action)
      }
      action()
    }

    func schedule(after date: DispatchQueue.SchedulerTimeType, interval: DispatchQueue.SchedulerTimeType.Stride, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
      DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
    }


    func schedule(after date: DispatchQueue.SchedulerTimeType, tolerance: DispatchQueue.SchedulerTimeType.Stride, options: DispatchQueue.SchedulerOptions?, _ action: @escaping () -> Void) {
      DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
    }
  }

  static var immediateWhenOnMainThreadScheduler: ImmediateWhenOnMainThreadScheduler {
    ImmediateWhenOnMainThreadScheduler()
  }

  struct ImmediateWhenOnMainThreadScheduler: Scheduler {
    typealias SchedulerTimeType = DispatchQueue.SchedulerTimeType
    typealias SchedulerOptions = DispatchQueue.SchedulerOptions

    var now: SchedulerTimeType {
      DispatchQueue.main.now
    }

    var minimumTolerance: SchedulerTimeType.Stride {
      DispatchQueue.main.minimumTolerance
    }

    func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
      guard Thread.isMainThread else {
        return DispatchQueue.main.schedule(options: options, action)
      }

      action()
    }

    func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
      DispatchQueue.main.schedule(after: date, tolerance: tolerance, options: options, action)
    }

    func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
      DispatchQueue.main.schedule(after: date, interval: interval, tolerance: tolerance, options: options, action)
    }
  }
}

typealias AnyDispatchQueueScheduler = AnyScheduler<DispatchQueue.SchedulerTimeType, DispatchQueue.SchedulerOptions>
extension AnyDispatchQueueScheduler {
  static var immediateOnMainQueue: Self {
    DispatchQueue.immediateWhenOnMainQueueScheduler.eraseToAnyScheduler()
  }

  static var immediateOnMainThread: Self {
    DispatchQueue.immediateWhenOnMainThreadScheduler.eraseToAnyScheduler()
  }
}

extension Scheduler {
  func eraseToAnyScheduler() -> AnyScheduler<SchedulerTimeType, SchedulerOptions> {
    AnyScheduler(self)
  }
}

struct AnyScheduler<SchedulerTimeType: Strideable, SchedulerOptions>: Scheduler where SchedulerTimeType.Stride: SchedulerTimeIntervalConvertible {
  private let _now: () -> SchedulerTimeType
  private let _minimumTolerance: () -> SchedulerTimeType.Stride
  private let _schedule: (SchedulerOptions?, @escaping () -> Void) -> Void
  private let _scheduleAfter: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Void
  private let _scheduleAfterInterval: (SchedulerTimeType, SchedulerTimeType.Stride, SchedulerTimeType.Stride, SchedulerOptions?, @escaping () -> Void) -> Cancellable
  init<S>(_ scheduler: S) where SchedulerTimeType == S.SchedulerTimeType, SchedulerOptions == S.SchedulerOptions, S: Scheduler {
    _now = { scheduler.now }
    _minimumTolerance = { scheduler.minimumTolerance }
    _schedule = scheduler.schedule(options:_:)
    _scheduleAfter = scheduler.schedule(after:tolerance:options:_:)
    _scheduleAfterInterval = scheduler.schedule(after:interval:tolerance:options:_:)
  }

  var now: SchedulerTimeType { _now() }

  var minimumTolerance: SchedulerTimeType.Stride { _minimumTolerance() }

  func schedule(options: SchedulerOptions?, _ action: @escaping () -> Void) {
    _schedule(options, action)
  }
  func schedule(after date: SchedulerTimeType, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) {
    _scheduleAfter(date, tolerance, options, action)
  }
  func schedule(after date: SchedulerTimeType, interval: SchedulerTimeType.Stride, tolerance: SchedulerTimeType.Stride, options: SchedulerOptions?, _ action: @escaping () -> Void) -> Cancellable {
    _scheduleAfterInterval(date, interval, tolerance, options, action)
  }
}

