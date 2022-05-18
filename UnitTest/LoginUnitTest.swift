//
//  LoginUnitTest.swift
//  NewsAppTests
//
//  Created by t032fj on 2022/05/10.
//

import XCTest
import RealmSwift
@testable import NewsApp

class LoginUnitTest: XCTestCase {
 
    var loginDependency: LoginDependency!
 
    override func setUpWithError() throws {
        super.setUp()

        self.loginDependency = LoginDependency()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
        
        self.loginDependency.removeUserDefaults()
        self.loginDependency.removeRealmData()
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
        
        let testUser = self.loginDependency.testModel.userDefaults.object(forKey: "User")
        XCTAssertNil(testUser)
        
        let testUserLogin = self.loginDependency.testModel.userDefaults.object(forKey: "userLogin")
        XCTAssertNil(testUserLogin)
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()

        loginDependency.testModel.LoginAction(idText: "1111", passwordText: "11111111") { success in
            XCTAssertTrue(success)
            
            let testUser = self.loginDependency.testModel.userDefaults.object(forKey: "User")
            XCTAssertNotNil(testUser)
            
            let userData = try! JSONDecoder().decode(User.self, from: testUser as! Data)
            XCTAssertEqual(userData.id, "1111")
            XCTAssertEqual(userData.password, "11111111")
        }
    }
    
    func testFailLogin() {
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        loginDependency.testModel.LoginAction(idText: "111", passwordText: "1111111") { success in
            XCTAssertFalse(success)
        }
    }
 
    func testisEmptyId() {
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        loginDependency.testModel.LoginAction(idText: "", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "IDを入力してください")
        }
    }
    
    func testForMissIdCount() {
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        loginDependency.testModel.LoginAction(idText: "11", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "IDは4文字で入力してください")
        }
    }
    
    func testIsEnptyPasswordCount() {
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        loginDependency.testModel.LoginAction(idText: "1111", passwordText: "") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "Passwordを入力してください")
        }
    }
    
    func testIsMissPasswordCount() {
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        loginDependency.testModel.LoginAction(idText: "1111", passwordText: "1111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "Passwordは8文字で入力してください")
        }
    }
    
    func testIsFailId() {
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        loginDependency.testModel.LoginAction(idText: "1112", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "idが違います")
        }
    }
    
    func testIsFailPassword() {
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        loginDependency.testModel.LoginAction(idText: "1111", passwordText: "11111112") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "passwordが違います")
        }
    }
    
    func testIsConfirmStoredUserInformation() {
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()

        let userId = loginDependency.testModel.user?.id
        XCTAssertEqual(userId, "1111")
        
        let userPassword = loginDependency.testModel.user?.password
        XCTAssertEqual(userPassword, "11111111")
    }
    
    func testIsConfirmUserExist() {
        
        loginDependency.setupUserInformation()
        
        loginDependency.testModel.confirmUser { success in
            XCTAssertTrue(success)
        }
    }
    
    func testIsConfirmUserNotExist() {
        
        loginDependency.testModel.confirmUser { success in
            XCTAssertFalse(success)
        }
    }
    
    func testIsRemoveUserData() {
        
        loginDependency.setupUserInformation()
        loginDependency.setupUserLoginInformation()
        
        let loginResult: Bool = self.loginDependency.testModel.userDefaults.bool(forKey: "userLogin")
        XCTAssertTrue(loginResult)
                
        let testUser = self.loginDependency.testModel.userDefaults.object(forKey: "User")
        XCTAssertNotNil(testUser)
        
        let userData = try! JSONDecoder().decode(User.self, from: testUser as! Data)
        XCTAssertEqual(userData.id, "1111")
        
        loginDependency.testModel.removeUser { success in
            XCTAssertTrue(success)
            
            let loginResult = self.loginDependency.testModel.userDefaults.object(forKey: "userLogin")
            XCTAssertNil(loginResult)
            
            let testUser = self.loginDependency.testModel.userDefaults.object(forKey: "User")
            XCTAssertNil(testUser)
        }
    }
    
    func testIsConfirmUserLoginSituation() {
        
        loginDependency.setupUserLoginInformation()
        loginDependency.testModel.confirmLogin { success in
            XCTAssertTrue(success)
        }
        
        loginDependency.setupUserLogoutInformation()
        loginDependency.testModel.confirmLogin { success in
            XCTAssertFalse(success)
        }
    }
    
    func testIsFailConfirmUserLogin() {
        
        loginDependency.testModel.confirmLogin { success in
            XCTAssertFalse(success)
        }
    }
    
    func testIsDeleteStoredArticleData() {
        
        loginDependency.setUpRealmData()
        
        let realmData = self.loginDependency.testModel.realm?.objects(RealmFeedItem.self)
        XCTAssertNotEqual(realmData?.count, 0)
        
        loginDependency.testModel.deleteStoreArticleData { success in
            XCTAssertTrue(success)
            
            let realmData = self.loginDependency.testModel.realm?.objects(RealmFeedItem.self)
            XCTAssertEqual(realmData?.count, 0)
        }
    }
    
    func testIsSuccessLingLoginAction() {
        
        let currentLoginObject = self.loginDependency.testModel.userDefaults.object(forKey: "userLogin")
        XCTAssertNil(currentLoginObject)
  
        loginDependency.setupLineUserLoginInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        let currentLoginSituation = self.loginDependency.testModel.userDefaults.bool(forKey: "userLogin")
        XCTAssertFalse(currentLoginSituation)
        
        loginDependency.testModel.lineLoginAction(accessToken: "11111111") { success in
            XCTAssertEqual(success, 1)
            
            let currentLoginSituation = self.loginDependency.testModel.userDefaults.bool(forKey: "userLogin")
            XCTAssertTrue(currentLoginSituation)
        }
    }
    
    func testIsFailLineLogin() {
        
        loginDependency.testModel.lineLoginAction(accessToken: "11111111") { success in
            XCTAssertEqual(success, 2)

        }
    }
    
    func testIsDifferUserExistWhenLineLogin() {
        
        let currentLoginObject = self.loginDependency.testModel.userDefaults.object(forKey: "userLogin")
        XCTAssertNil(currentLoginObject)
        
        loginDependency.setupUserInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        let currentLoginSituation = self.loginDependency.testModel.userDefaults.bool(forKey: "userLogin")
        XCTAssertFalse(currentLoginSituation)
        
        loginDependency.testModel.lineLoginAction(accessToken: "11111111") { success in
            XCTAssertEqual(success, 0)
        }
    }
    
    func testIsFailAccessTokenValue() {
        
        let currentLoginObject = self.loginDependency.testModel.userDefaults.object(forKey: "userLogin")
        XCTAssertNil(currentLoginObject)
    
        loginDependency.setupUserLogoutInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        let currentLoginSituation = self.loginDependency.testModel.userDefaults.bool(forKey: "userLogin")
        XCTAssertFalse(currentLoginSituation)
        
        loginDependency.testModel.lineLoginAction(accessToken: "1111") { success in
            XCTAssertEqual(success, 2)
            
            let currentLoginSituation = self.loginDependency.testModel.userDefaults.bool(forKey: "userLogin")
            XCTAssertFalse(currentLoginSituation)
        }
    }
    
    func testIsDifferLineUserExistWhenIdLogin() {
        
        loginDependency.setupLineUserLoginInformation()
        loginDependency.testModel.setupStoredUserInformation()
        
        loginDependency.testModel.LoginAction(idText: "1111", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "Lineでログインしてください")
        }
    }
    
    func testIsNothingUserLoginInformation() {
        
        loginDependency.testModel.LoginAction(idText: "1111", passwordText: "11111111") { success in
            XCTAssertFalse(success)
            
            let errorMessage = self.loginDependency.testModel.errorMessage
            XCTAssertEqual(errorMessage, "ユーザー情報がありません")
        }
    }
    
    
}

extension LoginUnitTest {
    
    struct LoginDependency {
        
        let testModel: LoginModel
        let userDefaults: UserDefaults
        static let suitName: String = "Test"
        var testUser = User(id: "1111", password: "11111111", feed: "selectFeed", login: false, accessTokeValue: "", subscription: false, subsciptInterval: 1.0)
        var testLineUser = User(id: "", password: "", feed: "selectFeed", login: false, accessTokeValue: "11111111", subscription: false, subsciptInterval: 1.0)
        var realm: Realm?
        
        init() {
            
            self.userDefaults = UserDefaults(suiteName: LoginUnitTest.LoginDependency.suitName)!
   
            let configuration = Realm.Configuration(inMemoryIdentifier: "TestLoginModel")
            self.realm = try! Realm(configuration: configuration)
            
            testModel = .init(userDefaults: self.userDefaults, realm: self.realm!)
        }

        func removeUserDefaults() {
            
            self.testModel.userDefaults.removePersistentDomain(forName: LoginUnitTest.LoginDependency.suitName)
        }
        
        func setupUserInformation() {
    
            if let userData: Data = try? JSONEncoder().encode(self.testUser) {
                self.testModel.userDefaults.set(userData, forKey: "User")
            }
        }
        
        func setupUserLoginInformation() {
            
            self.testModel.userDefaults.set(true, forKey: "userLogin")
        }
        
        func setupUserLogoutInformation() {
            
            self.testModel.userDefaults.set(false, forKey: "userLogin")
        }
        
        func setupLineUserLoginInformation() {
            
            if let userData: Data = try? JSONEncoder().encode(self.testLineUser) {
                self.testModel.userDefaults.set(userData, forKey: "User")
            }
        }
        
        func setUpRealmData() {
            
            let realmFeedItem = RealmFeedItem()
            realmFeedItem.title = "title"
            realmFeedItem.url = "http//"
            realmFeedItem.pubDate = "2022/1/1"
            
            try! self.testModel.realm?.write({
                self.testModel.realm?.add(realmFeedItem)
            })
        }
        
        func removeRealmData() {
            
            try! self.testModel.realm?.write {
                self.testModel.realm?.deleteAll()
            }
        }
    }
}
