//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Tuan on 2020/10/25.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class CodableFeedStore: FeedStore {
  private struct Cache: Codable {
    let feed: [LocalFeedImage]
    let timestamp: Date
  }
  
  private let storeURL: URL
  
  public init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  public func retrieve(completion: @escaping RetrieveCompletion) {
    guard let data = try? Data(contentsOf: storeURL) else {
      completion(.empty)
      return
    }
    
    do {
      let decoder = JSONDecoder()
      let cache = try decoder.decode(Cache.self, from: data)
      completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    catch {
      completion(.failure(error: error))
    }
  }
  
  public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    do {
      let encoder = JSONEncoder()
      let encoded = try encoder.encode(Cache(feed: items, timestamp: timestamp))
      try encoded.write(to: storeURL)
      completion(nil)
    } catch {
      completion(error)
    }
  }
  
  public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
    guard FileManager.default.fileExists(atPath: storeURL.path) else {
      return completion(nil)
    }
    
    do {
      try FileManager.default.removeItem(at: storeURL)
      completion(nil)
    }
    catch {
      completion(error)
    }
  }
}
