//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/08/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (Result<HTTPURLResponse, Error>) -> Void)
}

public final class RemoteFeedLoader {
  private let client: HTTPClient
  private let url: URL
  
  public enum Error: Swift.Error {
    case connectivity
    case invalidData
  }
  
  public init(url: URL, client: HTTPClient) {
    self.url = url
    self.client = client
  }
  
  public func load(completion: @escaping (Error) -> ()) {
    client.get(from: url) { result in
      switch result {
      case .success(let response):
        completion(.invalidData)
      case .failure(let error):
        completion(.connectivity)
      }
    }
  }
}
