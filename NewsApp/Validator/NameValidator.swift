//
//  NameValidator.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/04.
//

import Foundation

struct NameValidator: Validator {

    let name: String
    
    func validate() -> NameValidateResult {
        
        if name.isEmpty {
            return .required("名前が入力されていません")
        }
        
        if name.count > 8 {
            return .toolong(8)
        }
        
        return .none
    }
}

enum NameValidateResult: ValidationResult {
    
    case none
    case required(String)
    case toolong(Int)
    
    var isOk: Bool {  if case .none = self { return true } else { return false } }
}
