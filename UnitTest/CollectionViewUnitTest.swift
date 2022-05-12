//
//  CollectionViewUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/10.
//

import XCTest
import RealmSwift
@testable import NewsApp

class CollectionUnitTest: XCTestCase {
    
    var collectionDependency: CollectionDependency!
    
    override func setUpWithError() throws {
        
        self.collectionDependency = CollectionDependency()
    }
    
    override func tearDownWithError() throws {
        
        self.collectionDependency.removeUserDefaults()
        self.collectionDependency.removeRealmData()
    }
    
    func testExample() throws {
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testIsDeleteTableItems() {
        
        var testFeedItems: [FeedItem] = []
        
        testFeedItems = collectionDependency.testModel.filterFeedItems
        XCTAssertEqual(testFeedItems.count, 0)
        
        collectionDependency.testModel.filterFeedItems += [FeedItem(title: "title", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)]
        
        testFeedItems = collectionDependency.testModel.filterFeedItems
        XCTAssertEqual(testFeedItems.count, 1)
        
        collectionDependency.testModel.deleteTableItems()
        
        testFeedItems = collectionDependency.testModel.filterFeedItems
        XCTAssertEqual(testFeedItems.count, 0)
    }
    
    func testIsFetchUserFeed() {
        
        var selectedFeed: String = ""
        
        collectionDependency.setupUserInformation()
        
        selectedFeed = collectionDependency.testModel.selectFeed
        XCTAssertEqual(selectedFeed, "")
        
        collectionDependency.testModel.fetchUserFeed()
        
        selectedFeed = collectionDependency.testModel.selectFeed
        XCTAssertEqual(selectedFeed, "テスト")
    }
    
    func testIsSuccessSaveFeedItems() {
        
        let testFeedItems: [FeedItem] = [FeedItem(title: "title", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)]
        
        let testData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(testData!.count, 0)
        
        collectionDependency.testModel.saveFeedItems(feedItems: testFeedItems)
        
        let AfterTestData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(AfterTestData!.count, 1)
        
        AfterTestData?.forEach({ item in
            XCTAssertEqual(item.title, "title")
            XCTAssertEqual(item.url, "https://")
            XCTAssertEqual(item.pubDate, "2022/01/01")
        })
    }
    
    func testIsFailSaveFeedItems() {
        
        let testFeedItems: [[FeedItem]] = [
            [FeedItem(title: "", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)],
            [FeedItem(title: "title", url: "", pubDate: "2022/01/01", star: false, read: false, afterRead: false)],
            [FeedItem(title: "title", url: "https://", pubDate: "", star: false, read: false, afterRead: false)],
            [FeedItem(title: "Yahoo!ニュース・トピックス", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)]
        ]
        
        let testData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(testData!.count, 0)
        
        testFeedItems.forEach { feedItem in
            
            collectionDependency.testModel.saveFeedItems(feedItems: feedItem)
            
            let AfterTestData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
            XCTAssertNotEqual(AfterTestData!.count, 1)
        }
    }
    
    func testIsGetFeedUrl() {
        
        let topics: [String] = ["主要", "国内", "国際", "経済", "エンタメ", "スポーツ", "IT", "科学", "地域"]
        let topicsUrls: [String] = [
            "https://news.yahoo.co.jp/rss/topics/top-picks.xml",
            "https://news.yahoo.co.jp/rss/topics/domestic.xml",
            "https://news.yahoo.co.jp/rss/topics/world.xml",
            "https://news.yahoo.co.jp/rss/topics/business.xml",
            "https://news.yahoo.co.jp/rss/topics/entertainment.xml",
            "https://news.yahoo.co.jp/rss/topics/sports.xml",
            "https://news.yahoo.co.jp/rss/topics/it.xml",
            "https://news.yahoo.co.jp/rss/topics/science.xml",
            "https://news.yahoo.co.jp/rss/topics/local.xml"
        ]
        
        for (index, value) in topics.enumerated()  {
            
            collectionDependency.testModel.getFeedUrl(value)
            
            let feedUrl = collectionDependency.testModel.feedUrl
            XCTAssertEqual(feedUrl, topicsUrls[index])
        }
    }
    
    func testIsFailFetchStoredFeedData() {
        
        let testData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(testData!.count, 0)
        
        collectionDependency.testModel.fetchFeedDate()
        
        let filteredFeedItems = collectionDependency.testModel.filterFeedItems
        XCTAssertEqual(filteredFeedItems.count, 0)
    }
    
    func testIsSuccessFetchStoredFeedData() {
        
        var testFeedItems: [FeedItem] = []
        
        collectionDependency.setUpRealmData()
        
        testFeedItems = collectionDependency.testModel.filterFeedItems
        XCTAssertEqual(testFeedItems.count, 0)
        
        let testData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(testData!.count, 1)
        
        collectionDependency.testModel.fetchFeedDate()
        
        testFeedItems = collectionDependency.testModel.filterFeedItems
        XCTAssertNotEqual(testFeedItems.count, 0)
    }
    
    func testIsSuccessSaveStoredSubscriptFeedItems() {
        
        let testFeedItem = [FeedItem(title: "title", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)]
        
        collectionDependency.testModel.comparedFeedItem(feedItems: testFeedItem) { testedFeedItem in
            testedFeedItem.forEach { item in
                XCTAssertEqual(item.title, "title")
                XCTAssertEqual(item.url, "https://")
                XCTAssertEqual(item.pubDate, "2022/01/01")
            }
        }
    }
    
    func testIsFailSaveStoredSubscriptionFeedItems() {
        
        let testFeedItems = [FeedItem(title: "title", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)]
        
        collectionDependency.testModel.filterFeedItems += testFeedItems
        
        collectionDependency.testModel.comparedFeedItem(feedItems: testFeedItems) { comparedFeedItems in
            XCTAssertEqual(comparedFeedItems.count, 0)
        }
    }
    
    func testIsDeleteStoredFeedItems() {
        
        let testFeedItems = [FeedItem(title: "title", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)]
        
        let jsonEncoder = JSONEncoder()
        
        if let data = try? jsonEncoder.encode(testFeedItems) {
            
            collectionDependency.testModel.userDefaults?.set(data, forKey: "StoreFeedItems")
            
            let storeFeedItemsObject = collectionDependency.testModel.userDefaults?.object(forKey: "StoreFeedItems")
            XCTAssertNotNil(storeFeedItemsObject)
            
            collectionDependency.testModel.deleteStoredFeedItems()
            
            let afterStoreFeedItemsObject = collectionDependency.testModel.userDefaults?.object(forKey: "StoreFeedItems")
            XCTAssertNil(afterStoreFeedItemsObject)
        }
    }
    
    func testIsSaveStarFavoriteItems() {
        
        collectionDependency.setupFilterFeedItems()
        
        collectionDependency.testModel.saveStar(title: "title2")
        
        
    }
    
    func testIsChangeFilterFeedItemsNewOrder() {
        
        collectionDependency.setupFilterFeedItems()
        
        let beforeTestFeedItems = collectionDependency.testModel.filterFeedItems
        
        for (index, _) in beforeTestFeedItems.enumerated()  {
            
            print(index)
            if index < beforeTestFeedItems.count - 1 {
                XCTAssertLessThan(beforeTestFeedItems[index].pubDate, beforeTestFeedItems[index + 1].pubDate)
            }
        }
        
        collectionDependency.testModel.makingNewOrder(buttonTitle: "Old")
        
        let afterTestFeedItems = collectionDependency.testModel.filterFeedItems
        
        for (index, _) in afterTestFeedItems.enumerated()  {
            
            print(index)
            if index < afterTestFeedItems.count - 1 {
                XCTAssertGreaterThan(afterTestFeedItems[index].pubDate, afterTestFeedItems[index + 1].pubDate)
            }
        }
    }
    
    func testIsChangeFilterFeedItemsOldOrder() {
        
        let testFeedItems = [
            FeedItem(title: "title3", url: "https://", pubDate: "2022/01/03", star: false, read: false, afterRead: false),
            FeedItem(title: "title2", url: "https://", pubDate: "2022/01/02", star: false, read: false, afterRead: false),
            FeedItem(title: "title1", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)
        ]
        
        collectionDependency.testModel.filterFeedItems = testFeedItems
        
        let beforeTestFeedItems = collectionDependency.testModel.filterFeedItems
        
        for (index, _) in beforeTestFeedItems.enumerated()  {
            
            if index < beforeTestFeedItems.count - 1 {
                XCTAssertGreaterThan(beforeTestFeedItems[index].pubDate, beforeTestFeedItems[index + 1].pubDate)
            }
        }
        
        collectionDependency.testModel.makingNewOrder(buttonTitle: "New")
        
        let afterTestFeedItems = collectionDependency.testModel.filterFeedItems
        
        for (index, _) in afterTestFeedItems.enumerated()  {
            
            if index < afterTestFeedItems.count - 1 {
                XCTAssertLessThan(afterTestFeedItems[index].pubDate, afterTestFeedItems[index + 1].pubDate)
            }
        }
    }
    
    func testGetXMLData() {
        
        let testData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertNotEqual(testData!.count, 8)
        
        let articleUrl: String = "https://news.yahoo.co.jp/rss/topics/top-picks.xml"
        
        collectionDependency.testModel.feedUrl = articleUrl
        collectionDependency.testModel.getXMLData()
        
        let afterTestData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(afterTestData!.count, 8)
    }
}

extension CollectionUnitTest {
    
    struct CollectionDependency {
        
        let testModel: CollectionModel
        let userDefaults: UserDefaults
        static let suitName: String = "Test"
        var testUser = User(id: "1111", password: "11111111", feed: "テスト", login: false, accessTokeValue: "", subscription: false, subsciptInterval: 1.0)
        var testLineUser = User(id: "", password: "", feed: "テスト", login: false, accessTokeValue: "11111111", subscription: false, subsciptInterval: 1.0)
        var realm: Realm?
        
        init() {
            
            self.userDefaults = UserDefaults(suiteName: CollectionUnitTest.CollectionDependency.suitName)!
            
            let configuration = Realm.Configuration(inMemoryIdentifier: "TestLoginModel")
            self.realm = try! Realm(configuration: configuration)
            
            testModel = .init(userDefaults: self.userDefaults, realm: self.realm!)
        }
        
        func removeUserDefaults() {
            
            self.testModel.userDefaults?.removePersistentDomain(forName: CollectionUnitTest.CollectionDependency.suitName)
        }
        
        func setupUserLoginInformation() {
            
            self.testModel.userDefaults?.set(true, forKey: "userLogin")
        }
        
        func setupUserLogoutInformation() {
            
            self.testModel.userDefaults?.set(false, forKey: "userLogin")
        }
        
        func setupUserInformation() {
            
            if let userData: Data = try? JSONEncoder().encode(self.testUser) {
                self.testModel.userDefaults?.set(userData, forKey: "User")
            }
        }
        
        func setupLineUserLoginInformation() {
            
            if let userData: Data = try? JSONEncoder().encode(self.testLineUser) {
                self.testModel.userDefaults?.set(userData, forKey: "User")
            }
        }
        
        func setUpRealmData() {
            
            let realmFeedItem = RealmFeedItem()
            realmFeedItem.title = "title"
            realmFeedItem.url = "https://"
            realmFeedItem.pubDate = "2022/1/1"
            
            try! self.testModel.realm?.write({
                self.testModel.realm?.add(realmFeedItem)
            })
        }
        
        func setupFilterFeedItems() {
            
            let testFeedItems = [
                FeedItem(title: "title1", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false),
                FeedItem(title: "title2", url: "https://", pubDate: "2022/01/02", star: false, read: false, afterRead: false),
                FeedItem(title: "title3", url: "https://", pubDate: "2022/01/03", star: false, read: false, afterRead: false)
            ]
            
//            self.testModel.filterFeedItems = testFeedItems
            
            testFeedItems.forEach { feeditem in
                
                let realmFeedItem = RealmFeedItem()
                realmFeedItem.title = feeditem.title
                realmFeedItem.url = feeditem.url
                realmFeedItem.pubDate = feeditem.pubDate
                
                try! self.testModel.realm?.write({
                    self.testModel.realm?.add(realmFeedItem)
                })
            }
        }
        
        func removeRealmData() {
            
            try! self.testModel.realm?.write {
                self.testModel.realm?.deleteAll()
            }
        }
    }
}
