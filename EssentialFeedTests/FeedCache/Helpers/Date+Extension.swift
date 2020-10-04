//
//  Date+Extension.swift
//  EssentialFeedTests
//
//  Created by Tuan on 2020/10/04.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

extension Date {
  
  private var feedCacheMaxAgeInDays: Int {
    return 7
  }
  
  func minusFeedCacheMaxAge() -> Date {
    return adding(days: -feedCacheMaxAgeInDays)
  }
  
  private func adding(days: Int) -> Date {
    return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
  }
}

extension Date {
  func adding(seconds: Int) -> Date {
    return self + TimeInterval(seconds)
  }
}
