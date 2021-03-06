//
//  IdValidator.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/04.
//

import Foundation

struct IdValidator: Validator {

    let id: String
    
    func validate() -> IdValidateResult {
        
        if id.isEmpty {
            return .requiredPass("idが入力されていません")
        }
        
        if id.count != 4 {
            return .isIncorrectCount(4)
        }
        
        return .none
    }
}

enum IdValidateResult: ValidationResult {
    
    case none
    case requiredPass(String)
    case isIncorrectCount(Int)
    
    var isOk: Bool { if case .none = self { return true } else { return false } }
}

