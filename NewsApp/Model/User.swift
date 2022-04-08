//
//  User.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/04.
//

import Foundation

struct User: Codable {
    
    let id: String
    let name: String
    let email: String
    let password: String
    let feed: String
    let login: Bool
//    let firstLogin: Bool
}
