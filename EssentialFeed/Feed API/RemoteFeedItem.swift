//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Tuan on 2020/10/02.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

internal struct RemoteFeedItem: Decodable {
  let id: UUID
  let description: String?
  let location: String?
  let image: URL
}
 
