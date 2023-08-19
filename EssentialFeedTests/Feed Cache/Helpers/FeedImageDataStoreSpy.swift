//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 19.08.2023.
//

import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    typealias retrievalCompletion = (FeedImageDataStore.RetrievalResult) -> Void
    
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }
    
    private(set) var receivedMessages = [Message]()
    private(set) var retrievalCompletions = [retrievalCompletion]()
    
    func retrieve(dataFor url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func insert( image data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
}
