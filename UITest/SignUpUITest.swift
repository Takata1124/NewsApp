//
//  SignUITest.swift
//  NewsAppUITests
//
//  Created by t032fj on 2022/04/24.
//

import XCTest

class SignUpUITest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let idText = "1111"
        let passwordText = "11111111"
        
        let app = XCUIApplication()
        app.buttons["transSignUpButton"].tap()
        
        let viewTitle = app.navigationBars["SignUp"].waitForExistence(timeout: 2)
        XCTAssertTrue(viewTitle)
        
        let idTextField = app.textFields["idTextField"]
        XCTAssertTrue(idTextField.exists)
        idTextField.tap()
        idTextField.typeText(idText)
    
        let passwordTextField = app.textFields["passwordTextField"]
        XCTAssertTrue(passwordTextField.exists)
        passwordTextField.tap()
        passwordTextField.typeText(passwordText)
        
        app.buttons["SignUpButton"].tap()
        
        let rssViewTitle = app.navigationBars["RSS"].waitForExistence(timeout: 2)
        XCTAssertTrue(rssViewTitle)
    }
}
