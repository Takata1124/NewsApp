//
//  LoginModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/12.
//

import Foundation

class LoginModel {
    
    static let shared = LoginModel()
    static let notificationName = "LoginErrerMessage"
    let notificationCenter = NotificationCenter()
    
    private let userDefaults = UserDefaults.standard
    
    private var user: User?
    private var userId: String = ""
    private var userPassword: String = ""
    
    private var errorMessage: String = "" {
        didSet {
            notificationCenter.post(name: .init(rawValue: LoginModel.notificationName), object: errorMessage)
        }
    }
    
    private init() {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else {
            errorMessage = "ユーザー情報がありません"
            return
        }
        
        self.user = try! JSONDecoder().decode(User.self, from: data)
        self.userId = self.user!.id
        self.userPassword = self.user!.password
    }
    
    func alreadyConfirmLogin(completion: @escaping(Bool) -> Void) {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else {
            completion(false)
            return
        }
        
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        
        if user.login == true {
            return completion(true)
        }
        
        completion(false)
    }
    
    func lineLoginAction(accessToken: String, completion: @escaping(Bool) -> Void) {
      
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            
            if accessToken == user.accessTokeValue {
                
                let recodeUser: User = User(id: self.user!.id, password: self.user!.password, feed: self.user!.feed, login: true, accessTokeValue: self.user!.accessTokeValue, subscription: self.user!.subscription, subsciptInterval: self.user!.subsciptInterval)
                
                print(recodeUser.login)
                
                
                guard let data: Data = try? JSONEncoder().encode(recodeUser) else { return }
                
                userDefaults.setValue(data, forKey: "User")
  
                return completion(true)
            }
        }
        print("新規登録")
        
        completion(false)
    }
    
    func LoginAction(idText: String, passwordText: String, completion: @escaping(Bool) -> Void) {
        
        if self.user == nil {
            errorMessage = "ユーザー情報がありません"
            completion(false)
            return
        }
        
        let idValidator = IdValidator(id: idText)
        
        switch idValidator.validate() {
            
        case .none: break
        case .required(_):
            errorMessage = "idを入力してください"
        case .toolong(_):
            errorMessage = "idは4文字で入力してください"
        }
        
        let passwordValidator = PasswordValidator(password: passwordText)
        
        switch passwordValidator.validate() {
            
        case .none: break
        case .required(_):
            errorMessage = "パスワードを入力してください"
        case .toolong(_):
            errorMessage = "パスワードは8文字で入力してください"
        }
        
        if idValidator.isValid() && passwordValidator.isValid() {
            
            if userId != idText {
                errorMessage = "idが違います"
            }
            
            if userPassword != passwordText {
                errorMessage = "passwordが違います"
            }
            
            if userId == idText && userPassword == passwordText {
                
                let recodeUser: User = User(id: self.user!.id, password: self.user!.password, feed: self.user!.feed, login: true, accessTokeValue: self.user!.accessTokeValue, subscription: self.user!.subscription, subsciptInterval: self.user!.subsciptInterval)
  
                guard let data: Data = try? JSONEncoder().encode(recodeUser) else { return }
                userDefaults.setValue(data, forKey: "User")
                
                completion(true)
                return
            }
        } else {
            completion(false)
        }
    }
}
            
