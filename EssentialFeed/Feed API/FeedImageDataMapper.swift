//
//  FeedImageDataMapper.swift
//  EssentialFeed
//
//  Created by Георгий Акмен on 20.10.2023.
//

public final class FeedImageDataMapper {
    
    public enum Error: Swift.Error {
        case invalidData
    }
    
    public static func map (_ data: Data, from response: HTTPURLResponse) throws -> Data {
        guard response.isOK, !data.isEmpty else { throw Error.invalidData  }
        
        return data
    }
}
