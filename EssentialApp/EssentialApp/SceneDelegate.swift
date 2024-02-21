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
            feedLoader: makeRemoteFeedLoaderWithLocalFallback,
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
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader()
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .caching(to: localFeedLoader)
    }
    
    private func makeRemoteLoadMoreFeedLoader(with items: [FeedImage]) -> AnyPublisher<Paginated<FeedImage>, Error> {
        makeRemoteFeedLoader(with: items.last)
            .map { newItems in (items + newItems, newItems.isEmpty) }
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
        makePage(items, items.isEmpty)
    }
    
    private func makePage(_ items: [FeedImage], _ noNewItems: Bool) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: noNewItems ? nil : {
            self.makeRemoteLoadMoreFeedLoader(with: items)
        })
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
