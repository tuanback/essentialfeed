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
    let feed: [CodableFeedImage]
    let timestamp: Date
    
    var localFeed: [LocalFeedImage] {
      return feed.map { $0.local }
    }

  }
  
  private struct CodableFeedImage: Codable {
    private let id: UUID
    private let description: String?
    private let location: String?
    private let url: URL
    
    init(_ image: LocalFeedImage) {
      id = image.id
      description = image.description
      location = image.location
      url = image.url
    }
    
    var local: LocalFeedImage {
      return LocalFeedImage(id: id, description: description, location: location, url: url)
    }
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
      completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    catch {
      completion(.failure(error: error))
    }
  }
  
  public func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
    do {
      let encoder = JSONEncoder()
      let encoded = try encoder.encode(Cache(feed: items.map { CodableFeedImage($0) }, timestamp: timestamp))
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
