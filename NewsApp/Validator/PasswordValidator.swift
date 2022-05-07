//
//  PasswordValidator.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/04.
//

import Foundation

struct PasswordValidator: Validator {

    let password: String
    
    func validate() -> PasswordValidateResult {
        
        if password.isEmpty {
            return .requiredPass("パスワードが入力されていません")
        }
        
        if password.count != 8 {
            return .isIncorrectCount(8)
        }
        
        return .none
    }
}

enum PasswordValidateResult: ValidationResult {
    
    case none
    case requiredPass(String)
    case isIncorrectCount(Int)
    
    var isOk: Bool {  if case .none = self { return true } else { return false } }
}
