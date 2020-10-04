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
  private let calendar = Calendar(identifier: .gregorian)
  
  public typealias SaveResult = Error?
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
  }
  
  public func save(_ items: [FeedImage], completion: @escaping (SaveResult)->Void) {
    
    store.deleteCachedFeed { [weak self] error in
      guard let self = self else { return }
      if let cacheDeletionError = error {
        completion(cacheDeletionError)
        return
      }
      self.cache(items, with: completion)
    }
  }
  
  public func load(completion: @escaping (Result<[FeedImage], Error>) -> (Void)) {
    store.retrieve { [weak self] result in
      guard let strongSelf = self else { return }
      switch result {
      case let .found(localFeedImages, timestamp) where strongSelf.validate(timestamp):
        completion(.success(localFeedImages.toModels()))
      case .found:
        completion(.success([]))
      case .empty:
        completion(.success([]))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
  
  public func validateCache() {
    store.retrieve { [weak self] result in
      guard let strongSelf = self else { return }
      switch result {
      case let .found(_, timestamp) where strongSelf.validate(timestamp):
        break
      case .found:
        self?.store.deleteCachedFeed { _ in }
      case .empty:
        break
      case .failure(_):
        self?.store.deleteCachedFeed { _ in }
      }
    }
  }
 
  private let maxCacheAgeInDays: Int = 7
  private func validate(_ timestamp: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
      return false
    }
    return currentDate() < maxCacheAge
  }
  
  private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
    self.store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}

private extension Array where Element == FeedImage {
  func toLocal() -> [LocalFeedImage] {
    return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
  }
}

private extension Array where Element == LocalFeedImage {
  func toModels() -> [FeedImage] {
    return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
  }
}
