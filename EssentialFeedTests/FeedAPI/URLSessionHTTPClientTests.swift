//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Real Life Swift on 2020/08/30.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
  private let session: URLSession
  
  init(session: URLSession) {
    self.session = session
  }
  
  func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
    session.dataTask(with: url) { (_, _, error) in
      if let error = error {
        completion(.failure(error))
      }
    }.resume()
  }
}

class URLSessionHTTPClientTests: XCTestCase {
  
  func test_getFromURL_resumeDataTaskWithURL() {
    let url = URL(string: "http://any-url.com")!
    let session = URLSessionSpy()
    let task = URLSessionDataTaskSpy()
    
    session.stub(url: url, task: task)
    
    let sut = URLSessionHTTPClient(session: session)
    sut.get(from: url) { _ in }
    
    XCTAssertEqual(task.resumeCallCount, 1)
  }
  
  func test_getFromURL_failsOnRequestError() {
    let url = URL(string: "http://any-url.com")!
    let error = NSError(domain: "any error", code: 1)
    let session = URLSessionSpy()
    session.stub(url: url, error: error)
    
    let sut = URLSessionHTTPClient(session: session)
    
    let exp = expectation(description: "Wait for completion")
    
    sut.get(from: url) { result in
      switch result {
      case .failure(let receivedError as NSError):
        XCTAssertEqual(receivedError, error)
      default:
        XCTFail("Not received the designated error")
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  // MARK: - Helpers
  private class URLSessionSpy: URLSession {
    private var stubs = [URL: Stub]()
    
    private struct Stub {
      let task: URLSessionDataTask
      let error: Error?
    }
    
    func stub(url: URL, task: URLSessionDataTask = FakeURLSessionDataTask(), error: Error? = nil) {
      stubs[url] = Stub(task: task, error: error)
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
      guard let stub = stubs[url] else {
        fatalError("Couldn't fint stub for \(url)")
      }
      completionHandler(nil, nil, stub.error)
      return stub.task
    }
  }
  
  private class FakeURLSessionDataTask: URLSessionDataTask {}
  private class URLSessionDataTaskSpy: URLSessionDataTask {
    private(set) var resumeCallCount = 0
    
    override func resume() {
      resumeCallCount += 1
    }
  }
  
}
