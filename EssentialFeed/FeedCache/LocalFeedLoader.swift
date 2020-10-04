//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Tuan on 2020/10/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

private final class FeedCachePolicy {
  private let currentDate: () -> Date
  private let calendar = Calendar(identifier: .gregorian)
  private let maxCacheAgeInDays: Int = 7
  
  init(currentDate: @escaping () -> Date) {
    self.currentDate = currentDate
  }
  
  func validate(_ timestamp: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
      return false
    }
    return currentDate() < maxCacheAge
  }
}

public class LocalFeedLoader {
  
  private var store: FeedStore
  private let currentDate: () -> Date
  private let cachePolicy: FeedCachePolicy
  
  public init(store: FeedStore, currentDate: @escaping () -> Date) {
    self.store = store
    self.currentDate = currentDate
    self.cachePolicy = FeedCachePolicy(currentDate: currentDate)
  }
}

extension LocalFeedLoader {
  public typealias SaveResult = Error?
  
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
  
  private func cache(_ items: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
    self.store.insert(items.toLocal(), timestamp: currentDate()) { [weak self] error in
      guard self != nil else { return }
      completion(error)
    }
  }
}

extension LocalFeedLoader: FeedLoader {
  public func load(completion: @escaping (Result<[FeedImage], Error>) -> (Void)) {
    store.retrieve { [weak self] result in
      guard let strongSelf = self else { return }
      switch result {
      case let .found(localFeedImages, timestamp) where strongSelf.cachePolicy.validate(timestamp):
        completion(.success(localFeedImages.toModels()))
      case .found, .empty:
        completion(.success([]))
      case let .failure(error):
        completion(.failure(error))
      }
    }
  }
}

extension LocalFeedLoader {
  public func validateCache() {
    store.retrieve { [weak self] result in
      guard let strongSelf = self else { return }
      switch result {
      case let .found(_, timestamp) where strongSelf.cachePolicy.validate(timestamp):
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
