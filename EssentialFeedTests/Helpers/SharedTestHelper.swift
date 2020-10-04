//
//  SharedTestHelper.swift
//  EssentialFeedTests
//
//  Created by Tuan on 2020/10/04.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

func anyURL() -> URL {
  return URL(string: "any-url.com")!
}

func anyNSError() -> NSError {
  return NSError(domain: "any error", code: 1)
}
