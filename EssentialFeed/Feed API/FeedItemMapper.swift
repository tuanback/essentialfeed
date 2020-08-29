//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/08/29.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

final class FeedItemsMapper {
  
  private struct Root: Decodable {
    let items: [Item]
    
    var feed: [FeedItem] {
      return items.map { $0.item }
    }
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
  
  static func map(_ data: Data, from response: HTTPURLResponse) -> Result<[FeedItem], RemoteFeedLoader.Error> {
    guard response.statusCode == 200,
    let root = try? JSONDecoder().decode(Root.self, from: data) else {
      return .failure(.invalidData)
    }
    
    return .success(root.feed)
  }
}
