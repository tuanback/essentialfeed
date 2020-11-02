//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Tuan on 2020/11/01.
//  Copyright © 2020 Real Life Swift. All rights reserved.
//

import XCTest
import EssentialFeediOS
import EssentialFeed

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
  
  func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
    let image0 = makeImage(description: "a description", location: "a location")
    let image1 = makeImage(description: nil, location: "another location")
    let image2 = makeImage(description: "another description", location: nil)
    let image3 = makeImage(description: nil, location: nil)
    
    let (sut, loader) = makeSUT()
    
    sut.loadViewIfNeeded()
    
    XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 0)
    assertThat(sut, isRendering: [])
    
    loader.completeFeedLoading(with: [image0], at: 0)
    XCTAssertEqual(sut.numberOfRenderedFeedImageViews(), 1)
    assertThat(sut, isRendering: [image0])
    
    sut.simulateUserInitiatedFeedReload()
    loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
    assertThat(sut, isRendering: [image0, image1, image2, image3])
  }
  
  // MARK: - Helpers
  
  private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
    let loader = LoaderSpy()
    let sut = FeedViewController(loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(loader, file: file, line: line)
    return (sut, loader)
  }
  
  private func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
    guard sut.numberOfRenderedFeedImageViews() == feed.count else {
      return XCTFail("Expected \(feed.count) images, got \(sut.numberOfRenderedFeedImageViews()) instead.", file: file, line: line)
    }
    
    feed.enumerated().forEach { (index, image) in
      assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
    }
  }
  
  private func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int, file: StaticString = #file, line: UInt = #line) {
    let view = sut.feedImageView(at: index)
    
    guard let cell = view as? FeedImageCell else {
      return XCTFail("Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead", file: file, line: line)
    }
    
    XCTAssertEqual(cell.isShowingLocation, image.location != nil, file: file, line: line)
    XCTAssertEqual(cell.locationText, image.location, file: file, line: line)
    XCTAssertEqual(cell.descriptionText, image.description, file: file, line: line)
    
  }
  
  private func makeImage(description: String? = nil, location: String? = nil, url: URL = URL(string: "http://any-url.com")!) -> FeedImage {
    return FeedImage(id: UUID(), description: description, location: location, url: url)
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
    
    func completeFeedLoading(with images: [FeedImage] = [], at index: Int) {
      completions[index](.success(images))
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
  
  func numberOfRenderedFeedImageViews() -> Int {
    return tableView.numberOfRows(inSection: feedImagesSection)
  }
  
  func feedImageView(at row: Int) -> UITableViewCell? {
    let ds = tableView.dataSource
    let index = IndexPath(row: row, section: feedImagesSection)
    return ds?.tableView(tableView, cellForRowAt: index)
  }
  
  private var feedImagesSection: Int {
    return 0
  }
}

private extension FeedImageCell {
  var isShowingLocation: Bool {
    return !locationContainer.isHidden
  }
  
  var locationText: String? {
    return locationLabel.text
  }
  
  var descriptionText: String? {
    return descriptionLable.text
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
