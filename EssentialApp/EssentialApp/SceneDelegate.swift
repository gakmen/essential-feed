//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by  Gosha Akmen on 27.08.2023.
//

import UIKit
import Combine
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: NSPersistentContainer
            .defaultDirectoryURL()
            .appending(component: "feed-store.sqlite"))
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    private lazy var navigationController = UINavigationController (
        rootViewController: FeedUIComposer.composeFeedControllerWith (
            feedLoader: makeFeedLoaderWithLocalFallback,
            imageLoader: makeLocalImageLoaderWithRemoteFallback,
            selection: showComments
        )
    )
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
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
        localFeedLoader.validateCache { _ in }
    }
    
    private func makeFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        httpClient
            .getPublisher(url: FeedEndpoint.get().url(from: baseURL))
            .tryMap(FeedItemsMapper.map)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { [self] items in
                Paginated(items: items, loadMorePublisher: {
                    self.makeRemoteLoadMoreLoader(with: items)
                })
            }
            .caching(to: localFeedLoader)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(with items: [FeedImage]) -> AnyPublisher<Paginated<FeedImage>, Error> {
        httpClient
            .getPublisher(url: FeedEndpoint.get(after: items.last).url(from: baseURL))
            .tryMap(FeedItemsMapper.map)
            .map { [self] newItems in
                let allItems = items + newItems
                return Paginated(items: allItems, loadMorePublisher: newItems.isEmpty ? nil : {
                    self.makeRemoteLoadMoreLoader(with: allItems)
                })
            }
            .caching(to: localFeedLoader)
            .eraseToAnyPublisher()
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
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
