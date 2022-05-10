//
//  LoginUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/10.
//

import XCTest
@testable import NewsApp

class LoginUnitTest: XCTestCase {
    
    var loginModel: LoginModel!
 
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.loginModel = LoginModel.shared
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
    }
    
    func testExample() throws {
   
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSuccessLogin() {
        
        loginModel.LoginAction(idText: "1111", passwordText: "11111111") { success in
            XCTAssertTrue(success)
        }
    }
    
    func testFailLogin() {
        
        loginModel.LoginAction(idText: "111", passwordText: "1111111") { success in
            XCTAssertFalse(success)
        }
    }
 
    func testisEmptyId() {
        
        loginModel.LoginAction(idText: "", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginModel.errorMessage
            XCTAssertEqual(errorMessage, "idを入力してください")
        }
    }
    
    func testForMissIdCount() {
        
        loginModel.LoginAction(idText: "11", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginModel.errorMessage
            XCTAssertEqual(errorMessage, "idは4文字で入力してください")
        }
    }
    
    func testIsEnptyPasswordCount() {
        
        loginModel.LoginAction(idText: "1111", passwordText: "") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginModel.errorMessage
            XCTAssertEqual(errorMessage, "パスワードを入力してください")
        }
    }
    
    func testMissPasswordCount() {
        
        loginModel.LoginAction(idText: "1111", passwordText: "1111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginModel.errorMessage
            XCTAssertEqual(errorMessage, "パスワードは8文字で入力してください")
        }
    }
    
    func testMissId() {
        
        loginModel.LoginAction(idText: "1112", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginModel.errorMessage
            XCTAssertEqual(errorMessage, "idが違います")
        }
    }
    
    func testMissPassword() {
        
        loginModel.LoginAction(idText: "1111", passwordText: "11111112") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginModel.errorMessage
            XCTAssertEqual(errorMessage, "passwordが違います")
        }
    }
}
