//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Tuan on 2020/11/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedViewController: UITableViewController {
  
  private var loader: FeedLoader?
  
  public convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    refreshControl?.beginRefreshing()
    load()
  }
  
  @objc private func load() {
    refreshControl?.beginRefreshing()
    loader?.load { [weak self] _ in
      self?.refreshControl?.endRefreshing()
    }
  }
  
}
