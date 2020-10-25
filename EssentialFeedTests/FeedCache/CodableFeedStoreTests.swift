//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Real Life Swift on 2020/10/05.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
  private struct Cache: Codable {
    let feed: [LocalFeedImage]
    let timestamp: Date
  }
  
  private let storeURL: URL
  
  init(storeURL: URL) {
    self.storeURL = storeURL
  }
  
  func retrieve(completion: @escaping FeedStore.RetrieveCompletion) {
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
  
  func insert(_ items: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCompletion) {
    let encoder = JSONEncoder()
    let encoded = try! encoder.encode(Cache(feed: items, timestamp: timestamp))
    try! encoded.write(to: storeURL)
    completion(nil)
  }
}

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
  // - MARK: Helpers:
  private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
    let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func testSpecificStoreURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
  }
  
  private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: CodableFeedStore) {
    let exp = expectation(description: "Wait for cache retrieve completed")
    
    sut.insert(cache.feed, timestamp: cache.timestamp) { insertionError in
      XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
      exp.fulfill()
    }
    wait(for: [exp], timeout: 1.0)
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
    expect(sut, toRetrieve: expectedResult, file: file, line: line)
  }
  
  private func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
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
