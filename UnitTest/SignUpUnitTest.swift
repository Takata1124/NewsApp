//
//  SignUpUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/10.
//

import XCTest
@testable import NewsApp

class SignUpUnitTest: XCTestCase {
    
    var signUpModel: SignUpModel!
    
    override func setUpWithError() throws {
        
        self.signUpModel = SignUpModel.shared
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
    
    func testSuccessMakeUser() {
        
        signUpModel.makingUserData(idText: "1111", passwordText: "11111111") { success in
            XCTAssertTrue(success)
        }
    }
    
    func testIsEmptyId() {
        
        signUpModel.makingUserData(idText: "", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.signUpModel.errorMessage
            XCTAssertEqual(errorMessage, "idを入力してください")
        }
    }
    
    func testMissIdCount() {

        signUpModel.makingUserData(idText: "11", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.signUpModel.errorMessage
            XCTAssertEqual(errorMessage, "idは4文字で入力してください")
        }
    }
    
    func testIsEmptyPassword() {
        
        signUpModel.makingUserData(idText: "1111", passwordText: "") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.signUpModel.errorMessage
            XCTAssertEqual(errorMessage, "パスワードを入力してください")
        }
    }
    
    func testMissPasswordCount() {
        
        signUpModel.makingUserData(idText: "1111", passwordText: "1111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.signUpModel.errorMessage
            XCTAssertEqual(errorMessage, "パスワードは8文字で入力してください")
        }
    }
}
