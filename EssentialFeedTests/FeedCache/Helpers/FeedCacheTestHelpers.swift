//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Tuan on 2020/10/04.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation
import EssentialFeed

func uniqueItem() -> FeedImage {
  return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
}

func uniqueItems() -> (models: [FeedImage], local: [LocalFeedImage]) {
  let models = [uniqueItem(), uniqueItem()]
  let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
  return (models, local)
}
