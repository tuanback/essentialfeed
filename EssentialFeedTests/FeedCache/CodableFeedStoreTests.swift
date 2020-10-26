//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Real Life Swift on 2020/10/05.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    
    let storeURL = testSpecificStoreURL()
    try? FileManager.default.removeItem(at: storeURL)
  }
  
  override func tearDown() {
    super.tearDown()
    
    let storeURL = testSpecificStoreURL()
    try? FileManager.default.removeItem(at: storeURL)
  }
  
  func test_retrieve_deliversEmptyOnEmptyCache() {
    let sut = makeSUT()
    expect(sut, toRetrieve: .empty)
  }
  
  func test_retrieve_hasNoSideEffectOnEmptyCache() {
    let sut = makeSUT()
    expect(sut, toRetrieveTwice: .empty)
  }
  
  func test_retrieve_deliversInsertedValuesOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueItems().local
    let timestamp = Date()
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
    let sut = makeSUT()
    let feed = uniqueItems().local
    let timestamp = Date()
    
    insert((feed, timestamp), to: sut)
    
    expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
  }
  
  func test_retrieve_deliversFailureOnRetrievalError() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)
    
    expect(sut, toRetrieve: .failure(error: anyNSError()))
  }
  
  func test_retrieve_hasNoSideEffectsOnFailure() {
    let storeURL = testSpecificStoreURL()
    let sut = makeSUT(storeURL: storeURL)
    
    try! "invalid data".write(to: storeURL, atomically: true, encoding: .utf8)
    
    expect(sut, toRetrieveTwice: .failure(error: anyNSError()))
  }
  
  func test_insert_ovveridesPreviousInsertedCacheValues() {
    let sut = makeSUT()
    
    let firstInsertionError = insert((uniqueItems().local, Date()), to: sut)
    XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
    
    let latestFeed = uniqueItems().local
    let latestTimestamp = Date()
    let latestInsertionError = insert((latestFeed, latestTimestamp), to: sut)
    
    XCTAssertNil(latestInsertionError, "Expected to ovveride cache successfully")
    expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
  }
  
  func test_insert_deliversErrorOnInsertionError() {
    let invalidStoreURL = URL(string: "invalid://store-url")!
    let sut = makeSUT(storeURL: invalidStoreURL)
    let feed = uniqueItems().local
    let timestamp = Date()
    
    let insertionError = insert((feed, timestamp), to: sut)
    XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
  }
  
  func test_delete_hasNoSideEffectsOnEmptyCache() {
    let sut = makeSUT()
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected empty cach deletion to succeed")
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_emptiedPreviouslyInsertedCache() {
    let sut = makeSUT()
    insert((uniqueItems().local, Date()), to: sut)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNil(deletionError, "Expected non-empty cach deletion to succeed")
    expect(sut, toRetrieve: .empty)
  }
  
  func test_delete_deliversErrorOnDeletionError() {
    let noDeletePermissionURL = cachesDirectory()
    let sut = makeSUT(storeURL: noDeletePermissionURL)
    
    let deletionError = deleteCache(from: sut)
    
    XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
  }
  
  // - MARK: Helpers:
  private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func testSpecificStoreURL() -> URL {
    return cachesDirectory().appendingPathComponent("image-feed.store")
  }
  
  private func cachesDirectory() -> URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
  }
  
  @discardableResult
  private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache retrieve completed")
    var insertionError: Error?
    sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
      insertionError = receivedInsertionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return insertionError
  }
  
  private func deleteCache(from sut: FeedStore) -> Error? {
    let exp = expectation(description: "Wait for cache deletion completed")
    var deletionError: Error?
    sut.deleteCachedFeed { receivedDeletionError in
      deletionError = receivedDeletionError
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
    return deletionError
  }
  
  private func expect(_ sut: FeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  private func expect(_ sut: FeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for cache retrieval")
    
    sut.retrieve { (retrievedREsult) in
      switch (expectedResult, retrievedREsult) {
      case (.empty, .empty),
           (.failure, .failure):
        break
      case let (.found(expected), .found(retrieved)):
        XCTAssertEqual(retrieved.feed, expected.feed, file: file, line: line)
        XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
      default:
        XCTFail("Expected to retrieved \(expectedResult), got \(retrievedREsult) instead", file: file, line: line)
      }
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
}
