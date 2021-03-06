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
        
        if let _ = userDefaults.value(forKey: "User") as? Data {
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
        }
    }
    
    func LoginAction(idText: String, passwordText: String, completion: @escaping(Bool) -> Void) {
        
        if self.user == nil {
            errorMessage = "????????????????????????????????????"
            completion(false)
            return
        }
        
        if self.user?.accessTokeValue != "" {
            errorMessage = "Line?????????????????????????????????"
            completion(false)
            return
        }
        
        let idValidator = IdValidator(id: idText)
        
        switch idValidator.validate() {
            
        case .none: break
        case .requiredPass(_):
            errorMessage = "ID???????????????????????????"
        case .isIncorrectCount(_):
            errorMessage = "ID???4?????????????????????????????????"
        }
        
        let passwordValidator = PasswordValidator(password: passwordText)
        
        switch passwordValidator.validate() {
            
        case .none: break
        case .requiredPass(_):
            errorMessage = "Password???????????????????????????"
        case .isIncorrectCount(_):
            errorMessage = "Password???8?????????????????????????????????"
        }
        
        if idValidator.isValid() && passwordValidator.isValid() {
            
            if user?.id != idText {
                errorMessage = "ID???????????????"
            }
            
            if user?.password != passwordText {
                errorMessage = "Password???????????????"
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
        
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            
            if user.id != "" {
                errorMessage = "ID, Password?????????????????????????????????"
                completion(0)
                return
            }
            
            
            if accessToken == user.accessTokeValue {
                
                userDefaults.setValue(true, forKey: "userLogin")
                completion(1)
                return
                
            }
            
            completion(2)
            return
        }
        
        completion(2)
    }
}

