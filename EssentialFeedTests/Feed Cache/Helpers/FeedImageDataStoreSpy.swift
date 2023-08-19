//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by  Gosha Akmen on 19.08.2023.
//

import EssentialFeed

class FeedImageDataStoreSpy: FeedImageDataStore {
    typealias RetrievalCompletion = (RetrievalResult) -> Void
    typealias InsertionCompletion = (InsertionResult) -> Void
    
    enum Message: Equatable {
        case retrieve(dataFor: URL)
        case insert(data: Data, for: URL)
    }
    
    private(set) var receivedMessages = [Message]()
    private(set) var insertionCompletions = [InsertionCompletion]()
    private(set) var retrievalCompletions = [RetrievalCompletion]()
    
    func insert( image data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        receivedMessages.append(.insert(data: data, for: url))
        insertionCompletions.append(completion)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func retrieve(dataFor url: URL, completion: @escaping (RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataFor: url))
        retrievalCompletions.append(completion)
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
}
