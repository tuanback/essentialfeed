//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Tuan on 2020/10/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class LocalFeedLoader {
  
  private var store: FeedStore
  private let currentDate: () -> Date
  
  public typealias SaveResult = Error?
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func save(_ items: [FeedItem], completion: @escaping (SaveResult)->Void) {
    
    store.deleteCachedFeed { [weak self] error in
      guard let self = self else { return }
      if let cacheDeletionError = error {
        completion(cacheDeletionError)
        return
      }
      self.cache(items, with: completion)
    }
  }
  
  private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
    self.store.insert(items, timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}
