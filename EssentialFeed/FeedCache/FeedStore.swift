//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Tuan on 2020/10/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public enum RetrieveCachedFeedResult {
  case empty
  case found(feed: [LocalFeedImage], timestamp: Date)
  case failure(error: Error)
}

public protocol FeedStore {
  typealias DeletionCompletion = (Error?) -> Void
  typealias InsertionCompletion = (Error?) -> Void
  typealias RetrieveCompletion = (RetrieveCachedFeedResult) -> Void
  
  func deleteCachedFeed(completion: @escaping DeletionCompletion)
  func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
  func retrieve(completion: @escaping RetrieveCompletion)
}


public struct LocalFeedImage: Equatable {
  public let id: UUID
  public let description: String?
  public let location: String?
  public let url: URL
  
  public init(id: UUID, description: String?, location: String?, url: URL) {
    self.id = id
    self.description = description
    self.location = location
    self.url = url
  }
}
