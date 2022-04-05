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


