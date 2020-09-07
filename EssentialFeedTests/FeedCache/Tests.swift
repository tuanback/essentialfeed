//
//  Tests.swift
//  EssentialFeedTests
//
//  Created by Real Life Swift on 2020/09/07.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
  
  private var store: FeedStore
  init(store: FeedStore) {
    self.store = store
  }
  
  func save(_ items: [FeedItem]) {
    store.deleteCachedFeed()
  }
}

class FeedStore {
  var deleteCachedFeedCallCount = 0
  
  func deleteCachedFeed() {
    deleteCachedFeedCallCount += 1
  }
}

class CacheFeedUseCaseTests: XCTestCase {

  func test_init_doesNotDeleteCachUponCreation() {
    let store = FeedStore()
    _ = LocalFeedLoader(store: store)
    XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
  }

  func test_save_requestsCacheDeleteion() {
    let store = FeedStore()
    let sut = LocalFeedLoader(store: store)
    let items = [uniqueItem(), uniqueItem()]
    
    sut.save(items)
    
    XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
  }
  
  // MARK: - Helpers
  
  private func uniqueItem() -> FeedItem {
    return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
  }
  
  private func anyURL() -> URL {
    return URL(string: "any-url.com")!
  }
}
