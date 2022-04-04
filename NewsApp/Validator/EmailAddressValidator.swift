//
//  EmailAddressValidator.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/04.
//

import Foundation

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
