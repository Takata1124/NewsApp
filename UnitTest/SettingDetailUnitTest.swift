//
//  SettingDetailUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/18.
//

import XCTest
@testable import NewsApp

class SettingDetailUnitTest: XCTestCase {
    
    var settingDetailDependency: SettingDetailDependency!
    
    override func setUpWithError() throws {
        
        self.settingDetailDependency = SettingDetailDependency()
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
    
    func testIsSetupTimeLayout() {
        
        var currentTimeCount: Int = 0
        
        currentTimeCount = settingDetailDependency.testModel.timeArray.count
        XCTAssertEqual(currentTimeCount, 0)
        
        settingDetailDependency.testModel.setupTimeLayout()
        
        currentTimeCount = settingDetailDependency.testModel.timeArray.count
        XCTAssertNotEqual(currentTimeCount, 0)
        XCTAssertEqual(currentTimeCount, 24)
        
    }
    
    func testIsConfirmUserData() {
        
        let settingDetailViewController = SettingDetailViewController()
        settingDetailViewController.settingDetailModel = settingDetailDependency.testModel
        
        let user = settingDetailViewController.user
        XCTAssertNil(user)
        
        settingDetailDependency.setupUserInformation()
        
        settingDetailDependency.testModel.confirmUserData()
        
        if let user = settingDetailViewController.user {
            
            XCTAssertNotNil(user)
            XCTAssertEqual(user.id, self.settingDetailDependency.testUser.id)
            XCTAssertEqual(user.password, self.settingDetailDependency.testUser.password)
            XCTAssertEqual(user.feed, self.settingDetailDependency.testUser.feed)
        }
    }
}

extension SettingDetailUnitTest {
    
    struct SettingDetailDependency {
        
        let testModel: SettingDetailModel
        let userDefaults: UserDefaults
        static let suitName: String = "Test"
        var testUser = User(id: "1111", password: "11111111", feed: "テスト", login: false, accessTokeValue: "", subscription: false, subsciptInterval: 1.0)
        
        init() {
            
            userDefaults = UserDefaults(suiteName: SettingDetailUnitTest.SettingDetailDependency.suitName)!
            
            testModel = SettingDetailModel.init(userDefaults: userDefaults)
        }
        
        func setupUserInformation() {
            
            if let userData: Data = try? JSONEncoder().encode(self.testUser) {
                self.testModel.userDefaults.set(userData, forKey: "User")
            }
        }
    }
}
