//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Tuan on 2020/10/04.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

internal final class FeedCachePolicy {
  private static let calendar = Calendar(identifier: .gregorian)
  private static let maxCacheAgeInDays: Int = 7
  
  private init() {}
  internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
    guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
      return false
    }
    return date < maxCacheAge
  }
}
