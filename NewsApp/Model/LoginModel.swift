//
//  LoginModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/12.
//

import Foundation
import RealmSwift

class LoginModel {
    
    static let shared = LoginModel()
    static let notificationName = "LoginErrerMessage"
    let notificationCenter = NotificationCenter()
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let userDefaults: UserDefaults
    var user: User?
    var userId: String = ""
    var userPassword: String = ""
    
    var errorMessage: String = "" {
        didSet {
            notificationCenter.post(name: .init(rawValue: LoginModel.notificationName), object: errorMessage)
        }
    }
    
    var realm: Realm?

    init(userDefaults: UserDefaults = UserDefaults.standard, realm: Realm = try! Realm()) {
        
        self.userDefaults = userDefaults
        self.realm = realm

        setupStoredUserInformation()
    }
    
    func setupStoredUserInformation() {
        
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            self.user = try! JSONDecoder().decode(User.self, from: data)
            self.userId = self.user!.id
            self.userPassword = self.user!.password
        }
    }
    
    func confirmUser(completion: @escaping(Bool) -> Void) {
        
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func removeUser(completion: @escaping(Bool) -> Void) {
        
        userDefaults.removeObject(forKey: "userLogin")
        userDefaults.removeObject(forKey: "User")
       
        deleteStoreArticleData { success in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func confirmLogin(completion: @escaping(Bool) -> Void) {
        
        if userDefaults.bool(forKey: "userLogin") {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func deleteStoreArticleData(completion: @escaping(Bool) -> Void) {
        
        if let results = realm?.objects(RealmFeedItem.self) {
            try! realm?.write {
                self.realm?.delete(results)
                completion(true)
            }
        } else {
            completion(false)
        }
    }
    
    func LoginAction(idText: String, passwordText: String, completion: @escaping(Bool) -> Void) {
        
        if self.user == nil {
            errorMessage = "ユーザー情報がありません"
            completion(false)
            return
        }
        
        if self.user?.accessTokeValue != "" {
            errorMessage = "Lineでログインしてください"
            completion(false)
            return
        }
        
        let idValidator = IdValidator(id: idText)
        
        switch idValidator.validate() {
            
        case .none: break
        case .requiredPass(_):
            errorMessage = "idを入力してください"
        case .isIncorrectCount(_):
            errorMessage = "idは4文字で入力してください"
        }
        
        let passwordValidator = PasswordValidator(password: passwordText)
        
        switch passwordValidator.validate() {
            
        case .none: break
        case .requiredPass(_):
            errorMessage = "パスワードを入力してください"
        case .isIncorrectCount(_):
            errorMessage = "パスワードは8文字で入力してください"
        }
        
        if idValidator.isValid() && passwordValidator.isValid() {
            
            if userId != idText {
                errorMessage = "idが違います"
            }
            
            if userPassword != passwordText {
                errorMessage = "passwordが違います"
            }
            
            if LoginQuery(idText: idText, passwordText: passwordText) {
                
                let recodingUser: User = User(id: self.user!.id, password: self.user!.password, feed: self.user!.feed, login: true, accessTokeValue: self.user!.accessTokeValue, subscription: self.user!.subscription, subsciptInterval: self.user!.subsciptInterval)
                
                if let data: Data = try? JSONEncoder().encode(recodingUser) {
                    
                    userDefaults.setValue(true, forKey: "userLogin")
                    userDefaults.setValue(data, forKey: "User")
                    
                    completion(true)
                    return
                }
            }
        } else {
            completion(false)
        }
    }
    
    func LoginQuery(idText: String, passwordText: String) -> Bool {
        
        return userId == idText && userPassword == passwordText
    }
    
    func lineLoginAction(accessToken: String, completion: @escaping(Bool) -> Void) {
        
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            
            if accessToken == user.accessTokeValue {
                
                let recodingUser: User = User(id: self.user!.id, password: self.user!.password, feed: self.user!.feed, login: true, accessTokeValue: self.user!.accessTokeValue, subscription: self.user!.subscription, subsciptInterval: self.user!.subsciptInterval)
                
                if let data: Data = try? JSONEncoder().encode(recodingUser) {
                    userDefaults.setValue(data, forKey: "User")
                    userDefaults.setValue(true, forKey: "userLogin")
                    completion(true)
                    return
                }
            }
        }
        
        completion(false)
    }
}

