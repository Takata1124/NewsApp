//
//  Validator.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/03.
//

import Foundation

protocol Validator {
    
    associatedtype ResultType: ValidationResult
    func validate() -> ResultType
}

extension Validator {
    
    func isValid() -> Bool { validate().isOk }
}

protocol ValidationResult {
    
    var isOk: Bool { get }
}

struct EmailAddressValidator: Validator {
    
    let address: String
    
    func validate() -> EmailAddressValidateResult {
        
        if address.isEmpty {
            return .required("メールアドレスが入力されていません")
        }
        
        if address.last == " " {
            return .invalidFormat("末尾に空白が含まれてます")
        }
        
        if address.first == " " {
            return .invalidFormat("先頭に空白が含まれてます")
        }
        
        return .none
    }
}

enum EmailAddressValidateResult: ValidationResult {
    
    case none
    case required(String)
    case invalidFormat(String)
    
    var isOk: Bool {  if case .none = self { return true } else { return false } }
}

struct PasswordValidator: Validator {

    let password: String
    
    func validate() -> PasswordValidateResult {
        
        if password.isEmpty {
            return .required("パスワードが入力されていません")
        }
        
        if password.count > 6 {
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
