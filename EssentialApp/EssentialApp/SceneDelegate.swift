//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by  Gosha Akmen on 27.08.2023.
//

import UIKit
import CoreData
import EssentialFeed
import EssentialFeediOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let remoteFeedLoader = RemoteFeedLoader(client: remoteClient, url: remoteURL)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let feedViewController = FeedUIComposer.composeFeedControllerWith (
            feedLoader: remoteFeedLoader,
            imageLoader: remoteImageLoader)
        
        window?.rootViewController = feedViewController
        
        
        
        
    }
}

