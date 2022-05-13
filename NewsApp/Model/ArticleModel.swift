//
//  ArticleModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/15.
//

import Foundation
import RealmSwift

class ArticleModel {
    
    static let shared = ArticleModel()
    let realm: Realm?
    
    init(realm: Realm = try! Realm()) {

        self.realm = realm
    }
    
    func fetchStar(title: String) -> Bool {
        
        let predicate = NSPredicate(format: "title == %@", "\(title)")
        let result = realm?.objects(RealmFeedItem.self).filter(predicate)
        
        return result![0].star
    }
    
    func saveStar(title: String) {
        
        let predicate = NSPredicate(format: "title == %@", "\(title)")
        let result = realm?.objects(RealmFeedItem.self).filter(predicate)
        
        if result?[0].star == false {
            try! realm?.write{
                result?[0].star = true
            }
        } else {
            try! realm?.write{
                result?[0].star = false
            }
        }
    }
}
