//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Tuan on 2020/10/03.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  typealias RetrieveCompletion = (RetrieveCachedFeedResult) -> Void
  
  enum ReceivedMessage: Equatable {
    case deleteCachedFeed
    case insert([LocalFeedImage], Date)
    case retrieve
  }
  
  private(set) var receivedMessages = [ReceivedMessage]()
  
  private var deletionCompletions = [DeletionCompletion]()
  private var insertionCompletions = [InsertionCompletion]()
  private var retrieveCompletions = [RetrieveCompletion]()
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    deletionCompletions.append(completion)
    receivedMessages.append(.deleteCachedFeed)
  }
  
  func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    insertionCompletions.append(completion)
    receivedMessages.append(.insert(items, timestamp))
  }
  
  func retrieve(completion: @escaping RetrieveCompletion) {
    retrieveCompletions.append(completion)
    receivedMessages.append(.retrieve)
  }
  
  func completeDeletion(with error: Error, at index: Int = 0) {
    deletionCompletions[index](error)
  }
  
  func completeDeletionSuccessfully(at index: Int = 0) {
    deletionCompletions[index](nil)
  }
  
  func completeInsertion(with error: Error, at index: Int = 0) {
    insertionCompletions[index](error)
  }
  
  func completeInsertionSuccessfully(at index: Int = 0) {
    insertionCompletions[index](nil)
  }
  
  func completeRetrieve(with error: Error, at index: Int = 0) {
    retrieveCompletions[index](.failure(error: error))
  }
  
  func completeRetrieveWithEmptyCache(at index: Int = 0) {
    retrieveCompletions[index](.empty)
  }
  
  func completeRetrieveSuccessfully(items: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
    retrieveCompletions[index](.found(feed: items, timestamp: timestamp))
  }
}
