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
            return .required("パスワードが入力されていません")
        }
        
        if password.count != 6 {
            return .toolong(6)
        }
        
        return .none
    }
}

enum PasswordValidateResult: ValidationResult {
    
    case none
    case required(String)
    case toolong(Int)
    
    var isOk: Bool {  if case .none = self { return true } else { return false } }
}
