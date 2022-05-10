//
//  SignUpModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/13.
//

import Foundation

class SignUpModel {
    
    static let shared = SignUpModel()
    static let notificationName = "SignUpErrorMessage"
    let notificationCenter = NotificationCenter()
    
    var id: String = ""
    var password: String = ""

    let userDefaults = UserDefaults.standard
    
    private var errorMessage: String = "" {
        didSet {
            notificationCenter.post(name: .init(rawValue: SignUpModel.notificationName), object: errorMessage)
        }
    }

    init() { }
    
    func confirmUser(completion: @escaping(Bool) -> Void) {
        
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            self.errorMessage = "ユーザーデータが存在します"
            completion(true)
        } else {
            self.errorMessage = "ユーザーデータが存在しません"
            completion(false)
        }
    }
    
    func makingUserData(idText: String, passwordText: String, completion: @escaping(Bool) -> Void) {
        
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
            
            self.id = idText
            self.password = passwordText
            
            completion(true)
            return
        }
            
        completion(false)
    }
}
