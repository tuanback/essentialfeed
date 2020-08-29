//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/08/26.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
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
  
  public func load(completion: @escaping (Result<[FeedItem], Error>) -> ()) {
    client.get(from: url) { result in
      switch result {
      case .success(let (data, response)):
        if response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) {
          completion(.success(root.items.map { $0.item }))
        }
        else {
          completion(.failure(.invalidData))
        }
      case .failure:
        completion(.failure(.connectivity))
      }
    }
  }
}

private struct Root: Decodable {
  let items: [Item]
}

private struct Item: Decodable {
  let id: UUID
  let description: String?
  let location: String?
  let image: URL
  
  var item: FeedItem {
    return FeedItem(id: id, description: description, location: location, imageURL: image)
  }
}
