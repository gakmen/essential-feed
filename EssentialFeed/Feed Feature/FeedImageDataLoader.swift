//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by  Gosha Akmen on 08.07.2023.
//

public protocol FeedImageDataLoader {    
    func loadImageData(from url: URL) throws -> Data
}
