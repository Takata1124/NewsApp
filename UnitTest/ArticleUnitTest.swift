//
//  ArticleUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/12.
//

import XCTest
import RealmSwift
@testable import NewsApp

class ArticleUnitTest: XCTestCase {
    
    var articleDependency: ArticleDependency!

    override func setUpWithError() throws {
        super.setUp()
        
        self.articleDependency = ArticleDependency()
    }

    override func tearDownWithError() throws {
        super.tearDown()
        
        self.articleDependency.removeRealmData()
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
    
    func testIsConfirmStar() {
        
        var isStar: Bool?
        
        isStar = articleDependency.testModel.fetchStar(title: "title3")
        XCTAssertFalse(isStar!)
        
        isStar = articleDependency.testModel.fetchStar(title: "title5")
        XCTAssertTrue(isStar!)
    }
    
    func testIsChangeSavedStar() {
        
        var isStar: Bool?
        var testTitle: String = ""
        var predicate: NSPredicate?
        var filteredRealmObject: Results<RealmFeedItem>?
        
        testTitle = "title3"
        predicate = NSPredicate(format: "title == %@", "\(testTitle)")
        
        filteredRealmObject = articleDependency.testModel.realm?.objects(RealmFeedItem.self).filter(predicate!)
        isStar = filteredRealmObject?[0].star
        XCTAssertFalse(isStar!)
        
        articleDependency.testModel.saveStar(title: testTitle)
        
        filteredRealmObject = articleDependency.testModel.realm?.objects(RealmFeedItem.self).filter(predicate!)
        isStar = filteredRealmObject?[0].star
        XCTAssertTrue(isStar!)
        
        articleDependency.testModel.saveStar(title: testTitle)
        
        filteredRealmObject = articleDependency.testModel.realm?.objects(RealmFeedItem.self).filter(predicate!)
        isStar = filteredRealmObject?[0].star
        XCTAssertFalse(isStar!)
    }
}

extension ArticleUnitTest {
    
    struct ArticleDependency {
        
        let testModel: ArticleModel
        static let suitName: String = "Test"
        var realm: Realm?
        
        init() {
            
            let configuration = Realm.Configuration(inMemoryIdentifier: "TestSetting")
            self.realm = try! Realm(configuration: configuration)
            
            testModel = .init(realm: self.realm!)
            
            setupRealmFeedItems()
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
