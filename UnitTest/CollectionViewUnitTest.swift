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
        
        var realmFeedItems: Results<RealmFeedItem>?
        
        let testFeedItems: [FeedItem] = [FeedItem(title: "title", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)]
        
        realmFeedItems = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(realmFeedItems!.count, 0)
        
        collectionDependency.testModel.saveFeedItems(feedItems: testFeedItems)
        
        realmFeedItems = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(realmFeedItems!.count, 1)
        
        realmFeedItems?.forEach({ item in
            XCTAssertEqual(item.title, "title")
            XCTAssertEqual(item.url, "https://")
            XCTAssertEqual(item.pubDate, "2022/01/01")
        })
    }
    
    func testIsFailSaveFeedItems() {
        
        var realmFeedItems: Results<RealmFeedItem>?
        
        let testFeedItems: [[FeedItem]] = [
            [FeedItem(title: "", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)],
            [FeedItem(title: "title", url: "", pubDate: "2022/01/01", star: false, read: false, afterRead: false)],
            [FeedItem(title: "title", url: "https://", pubDate: "", star: false, read: false, afterRead: false)],
            [FeedItem(title: "Yahoo!ニュース・トピックス", url: "https://", pubDate: "2022/01/01", star: false, read: false, afterRead: false)]
        ]
        
        realmFeedItems = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(realmFeedItems!.count, 0)
        
        testFeedItems.forEach { feedItem in
            
            collectionDependency.testModel.saveFeedItems(feedItems: feedItem)
            
            let realmFeedItems = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
            XCTAssertNotEqual(realmFeedItems!.count, 1)
        }
    }
    
    func testIsGetFeedUrl() {
        
        for (index, value) in collectionDependency.topics.enumerated()  {
            
            collectionDependency.testModel.getFeedUrl(value)
            
            let feedUrl = collectionDependency.testModel.feedUrl
            XCTAssertEqual(feedUrl, collectionDependency.topicsUrls[index])
        }
    }
    
    func testIsFailFetchStoredFeedData() {
        
        let realmFeedItems = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(realmFeedItems!.count, 0)
        
        collectionDependency.testModel.fetchFeedDate()
        
        let filteredFeedItems = collectionDependency.testModel.filterFeedItems
        XCTAssertEqual(filteredFeedItems.count, 0)
    }
    
    func testIsSuccessFetchStoredFeedData() {
        
        var testFeedItems: [FeedItem] = []
        
        collectionDependency.setUpSingleRealmData()
        
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
    
    func testIsChangeSelectedSituationItems() {
        
        var testTitle: String = ""
        var predicate: NSPredicate?
        var realmFeedItemObject: Results<RealmFeedItem>?
        
        collectionDependency.setupRealmFeedItems()
        
        let testAfterRead = collectionDependency.testModel.filterFeedItems[1].read
        XCTAssertFalse(testAfterRead!)
        
        testTitle = collectionDependency.testModel.filterFeedItems[1].title
        predicate = NSPredicate(format: "title == %@", "\(testTitle)")
        realmFeedItemObject = collectionDependency.testModel.realm?.objects(RealmFeedItem.self).filter(predicate!)
        XCTAssertFalse(realmFeedItemObject![0].read)
        
        collectionDependency.testModel.saveSelected(index: 1)
        
        realmFeedItemObject = collectionDependency.testModel.realm?.objects(RealmFeedItem.self).filter(predicate!)
        XCTAssertTrue(realmFeedItemObject![0].read)
    }
    
    func testIsChangeStarSitiationItems() {
        
        collectionDependency.setupRealmFeedItems()
        
        let testTitle: String = "title2"
        let predicate = NSPredicate(format: "title == %@", "\(testTitle)")
        let realmFeedItem = collectionDependency.testModel.realm?.objects(RealmFeedItem.self).filter(predicate)
   
        if let currentStar = realmFeedItem?[0].star {
            XCTAssertFalse(currentStar)
        }
        
        collectionDependency.testModel.saveStar(title: "\(testTitle)")
        
        if let currentStar = realmFeedItem?[0].star {
            XCTAssertTrue(currentStar)
        }
    }
    
    func testIsChangeReadSituationItems() {
        
        collectionDependency.setupRealmFeedItems()
        
        let testTitle: String = "title2"
        let predicate = NSPredicate(format: "title == %@", "\(testTitle)")
        let realmFeedItem = collectionDependency.testModel.realm?.objects(RealmFeedItem.self).filter(predicate)
        
        if let currentRead = realmFeedItem?[0].afterRead {
            XCTAssertFalse(currentRead)
        }
        
        collectionDependency.testModel.saveAfterRead(title: "\(testTitle)")
        
        if let currentRead = realmFeedItem?[0].afterRead {
            XCTAssertTrue(currentRead)
        }
    }
    
    func testIsFilterStarItems() {
        
        var realmObject: Results<RealmFeedItem>?
        var realmObjectCount: Int = 0
        var filterFeedItemsCount: Int = 0
 
        collectionDependency.setupRealmFeedItems()
        
        realmObject = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        
        realmObjectCount = realmObject!.count
        XCTAssertEqual(realmObjectCount, 6)
        filterFeedItemsCount = collectionDependency.testModel.filterFeedItems.count
        XCTAssertEqual(filterFeedItemsCount, 5)
        
        collectionDependency.testModel.filterStar(isStarFilter: true, buttonTitle: "New")
        
        filterFeedItemsCount = collectionDependency.testModel.filterFeedItems.count
        XCTAssertEqual(filterFeedItemsCount, 3)
        
        let itemIsStar = collectionDependency.testModel.filterFeedItems[0].star
        XCTAssertTrue(itemIsStar!)
    }
    
    func testIsFilterReadItems() {
        
        var realmObject: Results<RealmFeedItem>?
        var realmObjectCount: Int = 0
        var filterFeedItems: Int = 0
 
        collectionDependency.setupRealmFeedItems()
        
        realmObject = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        
        realmObjectCount = realmObject!.count
        XCTAssertEqual(realmObjectCount, 6)
        filterFeedItems = collectionDependency.testModel.filterFeedItems.count
        XCTAssertEqual(filterFeedItems, 5)
        
        collectionDependency.testModel.filterRead(isReadFilter: true, buttonTitle: "New")
        
        filterFeedItems = collectionDependency.testModel.filterFeedItems.count
        XCTAssertEqual(filterFeedItems, 3)
        
        let itemIsRead = collectionDependency.testModel.filterFeedItems[0].read
        XCTAssertTrue(itemIsRead!)
    }
    
    func testIsFilterAfterReadItems() {
        
        var realmObject: Results<RealmFeedItem>?
        var realmObjectCount: Int = 0
        var filterFeedItems: Int = 0
 
        collectionDependency.setupRealmFeedItems()
        
        realmObject = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        
        realmObjectCount = realmObject!.count
        XCTAssertEqual(realmObjectCount, 6)
        filterFeedItems = collectionDependency.testModel.filterFeedItems.count
        XCTAssertEqual(filterFeedItems, 5)
        
        collectionDependency.testModel.filterAfterReadAction(isAfterReadFilter: true, buttonTitle: "New")
        
        filterFeedItems = collectionDependency.testModel.filterFeedItems.count
        XCTAssertEqual(filterFeedItems, 3)
        
        let itemIsAfterRead = collectionDependency.testModel.filterFeedItems[0].afterRead
        XCTAssertTrue(itemIsAfterRead!)
    }

    func testIsChangeFilterFeedItemsNewOrder() {
        
        collectionDependency.setupRealmFeedItems()
        
        let beforeTestFeedItems = collectionDependency.testModel.filterFeedItems
        
        for (index, _) in beforeTestFeedItems.enumerated()  {
            
            if index < beforeTestFeedItems.count - 1 {
                XCTAssertLessThan(beforeTestFeedItems[index].pubDate, beforeTestFeedItems[index + 1].pubDate)
            }
        }
        
        collectionDependency.testModel.makingNewOrder(buttonTitle: "Old")
        
        let afterTestFeedItems = collectionDependency.testModel.filterFeedItems
        
        for (index, _) in afterTestFeedItems.enumerated()  {
          
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
    
    func testIsGetXMLData() {
        
        let testData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertNotEqual(testData!.count, 8)
        
        let articleUrl: String = "https://news.yahoo.co.jp/rss/topics/top-picks.xml"
        
        collectionDependency.testModel.feedUrl = articleUrl
        collectionDependency.testModel.getXMLData()
        
        let afterTestData = collectionDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertEqual(afterTestData!.count, 8)
        
        let filterFeedItems = collectionDependency.testModel.filterFeedItems
        //+1は処理の順番がrealmDatabaseへ追加、Unitテスト終了、Updateとなっているため。
        XCTAssertEqual(filterFeedItems.count + 1, 8)
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
        
        func setUpSingleRealmData() {
            
            let realmFeedItem = RealmFeedItem()
            realmFeedItem.title = "title"
            realmFeedItem.url = "https://"
            realmFeedItem.pubDate = "2022/1/1"
            
            try! self.testModel.realm?.write({
                self.testModel.realm?.add(realmFeedItem)
            })
        }
        
        func setupRealmFeedItems() {
            
            let testFeedItems = [
                FeedItem(title: "title1", url: "https://111", pubDate: "2022/01/01", star: false, read: false, afterRead: false),
                FeedItem(title: "title2", url: "https://222", pubDate: "2022/01/02", star: false, read: false, afterRead: false),
                FeedItem(title: "title3", url: "https://333", pubDate: "2022/01/03", star: false, read: false, afterRead: false),
                FeedItem(title: "title4", url: "https://444", pubDate: "2022/01/04", star: true, read: true, afterRead: true),
                FeedItem(title: "title5", url: "https://555", pubDate: "2022/01/05", star: true, read: true, afterRead: true),
                FeedItem(title: "title6", url: "https://666", pubDate: "2022/01/06", star: true, read: true, afterRead: true),
            ]
            
            testFeedItems.forEach { feeditem in
                
                let realmFeedItem = RealmFeedItem()
                realmFeedItem.title = feeditem.title
                realmFeedItem.url = feeditem.url
                realmFeedItem.pubDate = feeditem.pubDate
                realmFeedItem.read = feeditem.read
                realmFeedItem.afterRead = feeditem.read
                realmFeedItem.star = feeditem.star
                
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
