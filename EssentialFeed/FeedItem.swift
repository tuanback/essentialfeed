//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/08/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public struct FeedItem: Equatable {
  let id: UUID
  let description: String?
  let location: String?
  let imageURL: URL
}
