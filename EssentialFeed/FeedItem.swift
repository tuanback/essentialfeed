//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/08/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable, Decodable {
  public let id: UUID
  public let description: String?
  public let location: String?
  public let imageURL: URL
  
  public init(id: UUID, description: String?, location: String?, imageURL: URL) {
    self.id = id
    self.description = description
    self.location = location
    self.imageURL = imageURL
  }
  
  private enum CodingKeys: String, CodingKey {
    case id
    case description
    case location
    case imageURL = "image"
  }
}
