//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by  Gosha Akmen on 08.10.2023.
//

public typealias RemoteImageCommentsLoader = RemoteLoader<[ImageComment]>

public extension RemoteImageCommentsLoader {
    convenience init(client: HTTPClient, url: URL) {
        self.init(client: client, url: url, mapper: ImageCommentsMapper.map)
    }
}
