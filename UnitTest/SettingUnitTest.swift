//
//  SettingUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/10.
//

import XCTest
import RealmSwift
@testable import NewsApp

class SettingUnitTest: XCTestCase {
    
    var settingDependency: SettingDependency!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //        self.settingModel = SettingModel.shared
        super.setUp()
        
        self.settingDependency = SettingDependency()
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        self.settingDependency.removeUserDefaults()
        self.settingDependency.removeRealmData()
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
    
    func testIsDeleteArticleData() {

        settingDependency.setUpRealmData()
        
        let realmData = self.settingDependency.testModel.realm.objects(RealmFeedItem.self)
        XCTAssertNotEqual(realmData.count, 0)
        
        settingDependency.testModel.deleteArticleData {
            let realmData = self.settingDependency.testModel.realm.objects(RealmFeedItem.self)
            
            XCTAssertEqual(realmData.count, 0)
        }
    }
    
    func testStoreUserLoginSituation() {
        
        settingDependency.testModel.UserLogout { success in
            XCTAssertTrue(success)
            
            let loginResult: Bool = self.settingDependency.testModel.userDefaults.bool(forKey: "userLogin")
            XCTAssertEqual(loginResult, false)
        }
    }
    
    func testIsDeleteSubscriptionData() {
        
        settingDependency.setUpSubscriptionData()

        if let data = settingDependency.testModel.userDefaults.data(forKey: "StoreFeedItems") {
            
            let jsonDecoder = JSONDecoder()
            
            if let storeData = try? jsonDecoder.decode([FeedItem].self, from: data) {
                XCTAssertNotEqual(storeData.count, 0)
            }
            
            settingDependency.testModel.deleteSubscriptionData {
         
                let data = self.settingDependency.testModel.userDefaults.data(forKey: "StoreFeedItems")
                XCTAssertNil(data)
            }
        }
    }
}

extension SettingUnitTest {
    
    struct SettingDependency {
        
        let testModel: SettingModel
        let userDefaults: UserDefaults
        static let suitName: String = "Test"
        var realm: Realm?
        
        init() {
            userDefaults = UserDefaults(suiteName: SettingUnitTest.SettingDependency.suitName)!
   
            let configuration = Realm.Configuration(inMemoryIdentifier: "TestSetting")
            self.realm = try! Realm(configuration: configuration)
            
            testModel = .init(userDefaults: self.userDefaults, realm: self.realm!)
        }
        
        func setUpRealmData() {
            
            let realmFeedItem = RealmFeedItem()
            realmFeedItem.title = "title"
            realmFeedItem.url = "http//"
            realmFeedItem.pubDate = "2022/1/1"
            
            try! self.testModel.realm.write({
                self.testModel.realm.add(realmFeedItem)
            })
        }
        
        func setUpSubscriptionData() {
            
            let temporaryFeedItem: [FeedItem] = [FeedItem(title: "title", url: "url", pubDate: "pubDate", star: false, read: false, afterRead: false)]
            
            let jsonEncoder = JSONEncoder()
            
            if let data = try? jsonEncoder.encode(temporaryFeedItem) {
                self.testModel.userDefaults.set(data, forKey: "StoreFeedItems")
            }
        }
 
        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: SettingUnitTest.SettingDependency.suitName)
        }
        
        func removeRealmData() {
            
            try! self.testModel.realm.write {
                self.testModel.realm.deleteAll()
            }
        }
    }
}
