//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by  Gosha Akmen on 27.08.2023.
//

import os
import UIKit
import Combine
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?

  private lazy var logger = Logger(subsystem: "ru.gakmen.essentialFeed", category: "main")

  private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(
    label: "com.essentialdeveloper.infra.queue",
    qos: .userInitiated,
    attributes: .concurrent
  ).eraseToAnyScheduler()

  private lazy var httpClient: HTTPClient = {
    URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
  }()

  private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!

  private lazy var store: FeedStore & FeedImageDataStore = {
    do {
      return try CoreDataFeedStore(storeURL: NSPersistentContainer
        .defaultDirectoryURL()
        .appending(component: "feed-store.sqlite"))

    } catch {
      assertionFailure("Couldn't instantiate a FeedStore, got error instead: \(error.localizedDescription)")
      logger.fault("Couldn't instantiate a FeedStore, got error instead: \(error.localizedDescription)")
      return NullStore()
    }
  }()

  private lazy var localFeedLoader: LocalFeedLoader = {
    LocalFeedLoader(store: store, currentDate: Date.init)
  }()

  private lazy var navigationController = UINavigationController (
    rootViewController: FeedUIComposer.composeFeedControllerWith (
      feedLoader: makeRemoteFeedLoaderWithLocalFallback,
      imageLoader: makeLocalImageLoaderWithRemoteFallback,
      selection: showComments
    )
  )

  convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore, scheduler: AnyDispatchQueueScheduler) {
    self.init()
    self.httpClient = httpClient
    self.store = store
    self.scheduler = scheduler
  }

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let scene = (scene as? UIWindowScene) else { return }

    window = UIWindow(windowScene: scene)
    configureWindow()
  }

  func configureWindow() {
    window?.rootViewController = navigationController
    window?.makeKeyAndVisible()
  }

  func sceneWillResignActive(_ scene: UIScene) {
    do {
      try localFeedLoader.validateCache()
    } catch {
      logger.error("Failed to validate cache with error: \(error.localizedDescription)")
    }
  }

  private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
    makeRemoteFeedLoader()
      .caching(to: localFeedLoader)
      .fallback(to: localFeedLoader.loadPublisher)
      .map(makeFirstPage)
      .eraseToAnyPublisher()
  }

  private func makeRemoteLoadMoreFeedLoader(with last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
    localFeedLoader.loadPublisher()
      .zip(makeRemoteFeedLoader(with: last))
      .map { (cachedItems, newItems) in (cachedItems + newItems, newItems.last) }
      .map(makePage)
      .caching(to: localFeedLoader)
  }

  private func makeRemoteFeedLoader(with lastItem: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
    httpClient
      .getPublisher(url: FeedEndpoint.get(after: lastItem).url(from: baseURL))
      .tryMap(FeedItemsMapper.map)
      .eraseToAnyPublisher()
  }

  private func makeFirstPage(_ items: [FeedImage]) -> Paginated<FeedImage> {
    makePage(items, items.last)
  }

  private func makePage(_ items: [FeedImage], _ last: FeedImage?) -> Paginated<FeedImage> {
    Paginated(items: items, loadMorePublisher: last.map { last in
      { self.makeRemoteLoadMoreFeedLoader(with: last) }
    })
  }

  private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
    let localImageLoader = LocalFeedImageDataLoader(store: store)

    return localImageLoader
      .loadImageDataPublisher(from: url)
      .fallback(to: { [httpClient, scheduler] in
        httpClient
          .getPublisher(url: url)
          .tryMap(FeedImageDataMapper.map)
          .caching(to: localImageLoader, using: url)
          .subscribe(on: scheduler)
          .eraseToAnyPublisher()
      })
      .subscribe(on: scheduler)
      .eraseToAnyPublisher()
  }

  private func showComments(for image: FeedImage) {
    let remoteURL = ImageCommentsEndpoint.get(image.id).url(from: baseURL)
    let commentsVC = CommentsUIComposer.composeCommentsControllerWith(commentsLoader: makeRemoteCommentsLoader(url: remoteURL))

    navigationController.pushViewController(commentsVC, animated: true)
  }

  private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
    { [httpClient] in
      httpClient
        .getPublisher(url: url)
        .tryMap(ImageCommentsMapper.map)
        .eraseToAnyPublisher()
    }
  }
}
