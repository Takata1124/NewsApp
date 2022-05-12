//
//  SignUpUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/10.
//

import XCTest
@testable import NewsApp

class SignUpUnitTest: XCTestCase {
    
    var signUpDependency: SignUpDependency!
    
    override func setUpWithError() throws {
        
        self.signUpDependency = SignUpDependency()
    }
    
    override func tearDownWithError() throws {
        
        self.signUpDependency.removeUserDefaults()
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
    
    func testSuccessMakeUser() {
        
        signUpDependency.testModel.makingUserData(idText: "1111", passwordText: "11111111") { success in
            XCTAssertTrue(success)
        }
    }
    
    func testIsFailEmptyId() {
        
        signUpDependency.testModel.makingUserData(idText: "", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.signUpDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "idを入力してください")
        }
    }
    
    func testIsFailIncorrectIdCount() {

        signUpDependency.testModel.makingUserData(idText: "11", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.signUpDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "idは4文字で入力してください")
        }
    }
    
    func testIsFailEmptyPassword() {
        
        signUpDependency.testModel.makingUserData(idText: "1111", passwordText: "") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.signUpDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "パスワードを入力してください")
        }
    }
    
    func testIsFailIncorrectPasswordCount() {
        
        signUpDependency.testModel.makingUserData(idText: "1111", passwordText: "1111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.signUpDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "パスワードは8文字で入力してください")
        }
    }
}

extension SignUpUnitTest {
    
    struct SignUpDependency {
        
        let testModel: SignUpModel
        let userDefaults: UserDefaults
        static let suitName: String = "Test"
        var testUser = User(id: "1111", password: "11111111", feed: "selectFeed", login: false, accessTokeValue: "", subscription: false, subsciptInterval: 1.0)
        
        init() {
            
            self.userDefaults = UserDefaults(suiteName: SignUpUnitTest.SignUpDependency.suitName)!
            testModel = .init(userDefaults: self.userDefaults)
        }

        func removeUserDefaults() {
            
            self.testModel.userDefaults.removePersistentDomain(forName: SignUpUnitTest.SignUpDependency.suitName)
        }
    }
}
