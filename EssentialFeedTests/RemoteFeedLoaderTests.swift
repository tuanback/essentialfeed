//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Real Life Swift on 2020/08/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
  
  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()
    XCTAssertTrue(client.requestedURLs.isEmpty)
  }
  
  func test_load_requestsDataFromURL() {
    let url = URL(string: "https://a.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url])
  }
  
  func test_loadTwice_requestsDataFromURLTwice() {
    let url = URL(string: "https://a.com")!
    let (sut, client) = makeSUT(url: url)
    
    sut.load { _ in }
    sut.load { _ in }
    
    XCTAssertEqual(client.requestedURLs, [url, url])
  }
  
  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    
    var capturedErrors = [RemoteFeedLoader.Error]()
    sut.load { capturedErrors.append($0) }
    
    let clientError = NSError(domain: "Test", code: 0)
    client.complete(with: clientError, at: 0)
    
    XCTAssertEqual(capturedErrors, [.connectivity])
  }
  
  func test_load_deliversErrorOnOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()
    
    [199, 201, 300, 400, 500].enumerated().forEach { (index, code) in
      var capturedErrors = [RemoteFeedLoader.Error]()
      sut.load { capturedErrors.append($0) }
      client.complete(withStatusCode: 400, at: index)
      
      XCTAssertEqual(capturedErrors, [.invalidData])
    }
  }
  
  func test_load_deleiversErrorOn200HTTPResponseWithInvalidJSON() {
    let (sut, client) = makeSUT()
    
    var capturedErrors = [RemoteFeedLoader.Error]()
    sut.load { capturedErrors.append($0) }
    
    let invalidJSON = Data(bytes: "invalid json".utf8)
    
    client.complete(withStatusCode: 200, data: invalidJSON)
    
    XCTAssertEqual(capturedErrors, [.invalidData])
  }
  
  // MARK: - Helpers
  private func makeSUT(url: URL = URL(string: "https://a.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteFeedLoader(url: url, client: client)
    return (sut, client)
  }
  
  private class HTTPClientSpy: HTTPClient {
    private var messages = [(url: URL, completion: (Result<(Data, HTTPURLResponse), Error>) -> Void)]()
    
    var requestedURLs: [URL] {
      return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
      messages.append((url, completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }
    
    func complete(withStatusCode code: Int, data: Data = Data(), at index: Int = 0) {
      let response = HTTPURLResponse(
        url: requestedURLs[index],
        statusCode: code,
        httpVersion: nil,
        headerFields: nil)!
      
      messages[index].completion(.success((data, response)))
    }
  }
  
}
