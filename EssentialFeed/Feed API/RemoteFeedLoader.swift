//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/08/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
  
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
  
  public func load(completion: @escaping (Result<[FeedItem], Error>) -> ()) {
    client.get(from: url) { [weak self] result in
      guard self != nil else { return }
      
      switch result {
      case .success(let (data, response)):
        completion(FeedItemsMapper.map(data, from: response))
      case .failure:
        completion(.failure(.connectivity))
      }
    }
  }
}
