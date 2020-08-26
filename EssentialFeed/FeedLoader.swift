//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/08/24.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

protocol FeedLoader {
  func load(completion: @escaping (Result<[FeedItem], Error>)->())
}
