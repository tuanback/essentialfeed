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
    let items: [RemoteFeedItem]
  }
  
  static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
    guard response.statusCode == 200,
    let root = try? JSONDecoder().decode(Root.self, from: data) else {
      throw RemoteFeedLoader.Error.invalidData
    }
    
    return root.items
  }
}
