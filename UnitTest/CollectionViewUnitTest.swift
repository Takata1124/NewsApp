//
//  CollectionViewUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/10.
//

import XCTest
@testable import NewsApp

class CollectionViewUnitTest: XCTestCase {
    
    var collectionModel: CollectionModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.collectionModel = CollectionModel.shared
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testGetXMLData() {
        
        let articleUrl: String = "https://news.yahoo.co.jp/rss/topics/top-picks.xml"
        collectionModel.getXMLData()
        collectionModel.feedUrl = articleUrl
        
        let count = collectionModel.filterFeedItems.count
        print(count)
        print(collectionModel.filterFeedItems)
    }
}
