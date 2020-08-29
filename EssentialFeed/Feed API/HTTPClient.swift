//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/08/29.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public protocol HTTPClient {
  func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void)
}
