//
//  RssUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/11.
//

import XCTest
@testable import NewsApp

class RssUnitTest: XCTestCase {
    
    var rssDependency: RssDependency!

    override func setUpWithError() throws {
    
        super.setUp()
        self.rssDependency = RssDependency()
    }

    override func tearDownWithError() throws {
        
        super.tearDown()
        self.rssDependency.removeUserDefaults()
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
    
    func testStoreUserInformation() {

        self.rssDependency.testModel.saveUseData(id: "1111", password: "11111111", accessTokeValue: "aaaa", indexPath: IndexPath(row: 1, section: 0)) { success in
            
            XCTAssertTrue(success)
            
            let userDefaults = self.rssDependency.testModel.userDefaults
            let loginSituation = userDefaults.bool(forKey: "userLogin")
            XCTAssertTrue(loginSituation)
            
            guard let userData = userDefaults.object(forKey: "User") else { return }
            let user: User = try! JSONDecoder().decode(User.self, from: userData as! Data)
            let id = user.id
            let password = user.password
            let token = user.accessTokeValue
            
            XCTAssertEqual(id, "1111")
            XCTAssertEqual(password, "11111111")
            XCTAssertEqual(token, "aaaa")
        }
    }
}

extension RssUnitTest {
    
    struct RssDependency {
        
        let testModel: RssModel
        let userDefaults: UserDefaults
        static let suitName: String = "Test"
        
        init() {
            userDefaults = UserDefaults(suiteName: RssUnitTest.RssDependency.suitName)!
            testModel = .init(userDefaults: userDefaults)
        }
        
        func removeUserDefaults() {
            userDefaults.removePersistentDomain(forName: RssUnitTest.RssDependency.suitName)
        }
    }
}
