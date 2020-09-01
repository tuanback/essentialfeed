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
  
  init(session: URLSession = .shared) {
    self.session = session
  }
  
  struct UnpectedValuesRepresent: Error {}
  
  func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
    session.dataTask(with: url) { (_, _, error) in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.failure(UnpectedValuesRepresent()))
      }
    }.resume()
  }
}

class URLSessionHTTPClientTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    URLProtocolStub.startInterceptingRequests()
  }
  
  override class func tearDown() {
    super.tearDown()
    URLProtocolStub.stopInterceptingRequests()
  }
  
  func test_getFromURL_performGetRequestWithURL() {
    let url = anyURL()
    let exp = expectation(description: "Wait for request")
    
    URLProtocolStub.observeRequests { (request) in
      XCTAssertEqual(request.url, url)
      XCTAssertEqual(request.httpMethod, "GET")
      exp.fulfill()
    }
    
    makeSUT().get(from: url) { (_) in }
    
    wait(for: [exp], timeout: 1.0)
  }
  
  func test_getFromURL_failsOnRequestError() {
    let anyData = Data("any data".utf8)
    let error = NSError(domain: "any error", code: 1)
    let nonHTTPURLResponse = URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    let anyHTTPURLResponse = HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    
    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nil, error: error))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: error))
    XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse, error: error))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: error))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: anyHTTPURLResponse, error: error))
    XCTAssertNotNil(resultErrorFor(data: anyData, response: nonHTTPURLResponse, error: nil))
  }
  
  func test_getFromURL_failsOnAllNilValues() {
    let _ = resultErrorFor(data: nil, response: nil, error: nil)
  }
  
  // MARK: - Helpers
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> URLSessionHTTPClient {
    let sut = URLSessionHTTPClient()
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }
  
  private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?,
                              file: StaticString = #file, line: UInt = #line) -> Error? {
    URLProtocolStub.stub(data: nil, response: nil, error: error)
    
    let sut = makeSUT(file: file, line: line)
    
    let exp = expectation(description: "Wait for completion")
    
    var receivedError: Error?
    sut.get(from: anyURL()) { result in
      switch result {
      case .failure(let error):
        receivedError = error
      default:
        XCTFail("Not received the designated error", file: file, line: line)
      }
      
      exp.fulfill()
    }
    
    wait(for: [exp], timeout: 1.0)
    return receivedError
  }
  
  private func anyURL() -> URL {
    URL(string: "http://any-url.com")!
  }
  
  private class URLProtocolStub: URLProtocol {
    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?
    
    private struct Stub {
      let data: Data?
      let response: URLResponse?
      let error: Error?
    }
    
    static func stub(data: Data?, response: URLResponse?, error: Error?) {
      stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
      requestObserver = observer
    }
    
    static func startInterceptingRequests() {
      URLProtocol.registerClass(URLProtocolStub.self)
    }
    
    static func stopInterceptingRequests() {
      URLProtocol.unregisterClass(URLProtocolStub.self)
      stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
      requestObserver?(request)
      return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
      return request
    }
    
    override func startLoading() {
      if let data = URLProtocolStub.stub?.data {
        client?.urlProtocol(self, didLoad: data)
      }
      
      if let response = URLProtocolStub.stub?.response {
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
      }
      
      if let error = URLProtocolStub.stub?.error {
        client?.urlProtocol(self, didFailWithError: error)
      }
      
      client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
  }
}
