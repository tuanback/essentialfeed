//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Real Life Swift on 2020/09/04.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

  func test_endToEndTestServerGetFeedResult_matchesFixedTestAccoutData() {
    switch getResult() {
    case let .success(items):
      XCTAssertEqual(items.count, 8)
    case let .failure(error):
      XCTFail("Expected successfully feed result, got \(error) instead")
    default:
      XCTFail("Expected successful feed result, got no result instead")
    }
  }

  private func getResult() -> Result<[FeedItem], Error>? {
    let url = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    let client = URLSessionHTTPClient()
    let loader = RemoteFeedLoader(url: url, client: client)
    
    let exp = expectation(description: "Wait for load completion")
    
    var receivedResult: Result<[FeedItem], Error>?
    loader.load { (result) in
      receivedResult = result
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 8.0)
    return receivedResult
  }
  
}
