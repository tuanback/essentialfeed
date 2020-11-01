//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Tuan on 2020/11/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UITableViewController {
  
  private var loader: FeedLoader?
  
  convenience init(loader: FeedLoader) {
    self.init()
    self.loader = loader
  }
  
  override func viewDidLoad() {
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

class FeedViewControllerTests: XCTestCase {
  
  func test_loadFeedActions_requestFeedFromLoader() {
    let (sut, loader) = makeSUT()
    
    XCTAssertEqual(loader.loadCallCount, 0)
  
    sut.loadViewIfNeeded()
    
    XCTAssertEqual(loader.loadCallCount, 1)
  
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 2)
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(loader.loadCallCount, 3)
  }
  
  func test_viewDidLoad_showsLoadingIndicator() {
    let (sut, loader) = makeSUT()
    
    sut.loadViewIfNeeded()
    XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    
    loader.completeFeedLoading(at: 0)
    XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    
    sut.simulateUserInitiatedFeedReload()
    XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    
    loader.completeFeedLoading(at: 1)
    XCTAssertEqual(sut.isShowingLoadingIndicator, false)
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(loader, file: file, line: line)
    return (sut, loader)
  }
  
  class LoaderSpy: FeedLoader {
    typealias Completion = (Result<[FeedImage], Error>) -> ()
    
    private var completions = [Completion]()
    var loadCallCount: Int {
      return completions.count
    }
    
    func load(completion: @escaping (Result<[FeedImage], Error>) -> ()) {
      completions.append(completion)
    }
    
    func completeFeedLoading(at index: Int) {
      completions[index](.success([]))
    }
  }
}

private extension FeedViewController {
  func simulateUserInitiatedFeedReload() {
    refreshControl?.simulatePullToRefresh()
  }
  
  var isShowingLoadingIndicator: Bool {
    return refreshControl?.isRefreshing == true
  }
}

private extension UIRefreshControl {
  func simulatePullToRefresh() {
    allTargets.forEach({ (target) in
      actions(forTarget: target, forControlEvent: .valueChanged)?.forEach({
        (target as NSObject).perform(Selector($0))
      })
    })
  }
}
