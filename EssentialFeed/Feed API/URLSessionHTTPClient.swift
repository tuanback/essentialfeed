//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Real Life Swift on 2020/09/04.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
  private let session: URLSession
  
  public init(session: URLSession = .shared) {
    self.session = session
  }
  
  struct UnpectedValuesRepresent: Error {}
  
  public func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), Error>) -> Void) {
    session.dataTask(with: url) { (data, response, error) in
      if let error = error {
        completion(.failure(error))
      } else if let data = data, let response = response as? HTTPURLResponse {
        completion(.success((data, response)))
      } else {
        completion(.failure(UnpectedValuesRepresent()))
      }
    }.resume()
  }
}
