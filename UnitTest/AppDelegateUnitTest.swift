//
//  AppDelgateUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/20.
//

import XCTest
import RealmSwift
import BackgroundTasks
@testable import NewsApp

class AppDelegateUnitTest: XCTestCase {
    
    var appDelegateDependency: AppDelegateDependency!
    
    override func setUpWithError() throws {
        super.setUp()
        
        self.appDelegateDependency = AppDelegateDependency()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
        
        //        self.appDelegateDependency.removeRealmData()
        //        self.appDelegateDependency.removeUserDefaults()
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
    
    func testIsSaveUserSubscription() {
        
        appDelegateDependency.setupUserInformation()
        
        if let data: Data = appDelegateDependency.testModel.userDefaults?.value(forKey: "User") as? Data {
            let user = try! JSONDecoder().decode(User.self, from: data)
            XCTAssertFalse(user.subscription)
        }
        
        appDelegateDependency.testModel.saveUserSubscription(subscription: true)
        
        if let data: Data = appDelegateDependency.testModel.userDefaults?.value(forKey: "User") as? Data {
            let user = try! JSONDecoder().decode(User.self, from: data)
            XCTAssertTrue(user.subscription)
        }
    }
    
    func testIsSaveUserInterbalTime() {
        
        appDelegateDependency.setupUserInformation()
        
        if let data: Data = appDelegateDependency.testModel.userDefaults?.value(forKey: "User") as? Data {
            let user = try! JSONDecoder().decode(User.self, from: data)
            XCTAssertEqual(user.subsciptInterval, 1.0)
        }
        
        appDelegateDependency.testModel.saveUserInterbalTime(interbalTime: 20.0)
        
        if let data: Data = appDelegateDependency.testModel.userDefaults?.value(forKey: "User") as? Data {
            let user = try! JSONDecoder().decode(User.self, from: data)
            XCTAssertEqual(user.subsciptInterval, 20.0)
        }
    }
    
    func testIsCompareStoreFeedItemsWithSubscriptedItems() {
        
        var currentIsNotificationAlert: Bool = false
        
        appDelegateDependency.setupRealmFeedItems()
        
        currentIsNotificationAlert = appDelegateDependency.testModel.isNotificationAlert
        
        XCTAssertFalse(currentIsNotificationAlert)
        
        appDelegateDependency.setupSameStoreFeedItems()
        appDelegateDependency.testModel.compareStoreAlert()
         
        currentIsNotificationAlert = appDelegateDependency.testModel.isNotificationAlert
        XCTAssertFalse(currentIsNotificationAlert)
        
        appDelegateDependency.setupDifferStoredFeedItems()
        appDelegateDependency.testModel.compareStoreAlert()
        
        currentIsNotificationAlert = appDelegateDependency.testModel.isNotificationAlert
        
        XCTAssertTrue(currentIsNotificationAlert)
    }
}

extension AppDelegateUnitTest {
    
    struct AppDelegateDependency {
        
        let testModel: AppDelegateModel
        let userDefaults: UserDefaults
        static let suitName: String = "Test"
        var realm: Realm?
        
        var testUser = User(id: "1111", password: "11111111", feed: "テスト", login: false, accessTokeValue: "", subscription: false, subsciptInterval: 1.0)
        
        init() {
            userDefaults = UserDefaults(suiteName: AppDelegateUnitTest.AppDelegateDependency.suitName)!
            
            let configuration = Realm.Configuration(inMemoryIdentifier: "TestLoginModel")
            self.realm = try! Realm(configuration: configuration)
            
            testModel = .init(userDefaults: self.userDefaults, realm: self.realm!)
        }
        
        func setupUserInformation() {
            
            if let userData: Data = try? JSONEncoder().encode(self.testUser) {
                self.testModel.userDefaults?.set(userData, forKey: "User")
            }
        }
        
        func removeUserDefaults() {
            
            self.testModel.userDefaults?.removePersistentDomain(forName: AppDelegateUnitTest.AppDelegateDependency.suitName)
        }
        
        func removeRealmData() {
            
            try! self.testModel.realm?.write {
                self.testModel.realm?.deleteAll()
            }
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
        
        func setupDifferStoredFeedItems() {
            
            let temporaryFeedItem: [FeedItem] = [FeedItem(title: "title7", url: "https://777", pubDate: "2022/01/07", star: true, read: true, afterRead: true)]
            
            if let data = try? JSONEncoder().encode(temporaryFeedItem) {
                userDefaults.set(data, forKey: "StoreFeedItems")
            }
        }
        
        func setupSameStoreFeedItems() {
            
            let temporaryFeedItem: [FeedItem] = [FeedItem(title: "title6", url: "https://666", pubDate: "2022/01/6", star: true, read: true, afterRead: true)]
            
            if let data = try? JSONEncoder().encode(temporaryFeedItem) {
                userDefaults.set(data, forKey: "StoreFeedItems")
            }
        }
    }
}
