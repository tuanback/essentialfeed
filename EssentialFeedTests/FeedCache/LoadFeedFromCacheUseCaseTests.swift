//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Tuan on 2020/10/03.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
  
  func test_init_doesNotMessageStoreUponCreation() {
    let (_, store) = makeSUT()
    XCTAssertEqual(store.receivedMessages, [])
  }
  
  func test_load_requestCacheRetrieval() {
    let (sut, store) = makeSUT()
    sut.load()
    
    XCTAssertEqual(store.receivedMessages, [.retrieve])
  }
  
  // MARK: - Helpers
  
  private func makeSUT(currentDate: @escaping () -> (Date) = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
    let store = FeedStoreSpy()
    let sut = LocalFeedLoader(store: store, currentDate: currentDate)
    
    trackForMemoryLeaks(store, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, store)
  }
  
}
