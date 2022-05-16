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

    var errorMessage: String = "" {
        didSet {
            notificationCenter.post(name: .init(rawValue: LoginModel.notificationName), object: errorMessage)
        }
    }
    
    var realm: Realm?

    init(userDefaults: UserDefaults = UserDefaults.standard, realm: Realm = try! Realm()) {
        
        self.userDefaults = userDefaults
        self.realm = realm

    }
    
    func setupStoredUserInformation() {

        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            self.user = try! JSONDecoder().decode(User.self, from: data)
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
            errorMessage = "IDを入力してください"
        case .isIncorrectCount(_):
            errorMessage = "IDは4文字で入力してください"
        }
        
        let passwordValidator = PasswordValidator(password: passwordText)
        
        switch passwordValidator.validate() {
            
        case .none: break
        case .requiredPass(_):
            errorMessage = "Passwordを入力してください"
        case .isIncorrectCount(_):
            errorMessage = "Passwordは8文字で入力してください"
        }
        
        if idValidator.isValid() && passwordValidator.isValid() {
            
            if user?.id != idText {
                errorMessage = "IDが違います"
            }
            
            if user?.password != passwordText {
                errorMessage = "Passwordが違います"
            }
            
            if LoginQuery(idText: idText, passwordText: passwordText) {
                
                userDefaults.setValue(true, forKey: "userLogin")
                
                completion(true)
                return
            }
        } else {
            completion(false)
        }
    }
    
    func LoginQuery(idText: String, passwordText: String) -> Bool {
        
        return user?.id == idText && user?.password == passwordText
    }
    
    func lineLoginAction(accessToken: String, completion: @escaping(Int) -> Void) {

        guard let id = self.user?.id else {
            completion(2)
            return
        }
        
        if id != "" {
            errorMessage = "ID, Passwordでログインしてください"
            completion(0)
            return
        }
        
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            
            if accessToken == user.accessTokeValue {
                
                userDefaults.setValue(true, forKey: "userLogin")
                completion(1)
                return
            }
        }
        
        completion(2)
    }
}

