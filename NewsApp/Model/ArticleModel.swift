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
    let realm = try! Realm()
    
    init() {}
    
    func saveStar(title: String) {
        
        let predicate = NSPredicate(format: "title == %@", "\(title)")
        let result = realm.objects(RealmFeedItem.self).filter(predicate)
        
        if result[0].star == false {
            do{
              try realm.write{
                  result[0].star = true
              }
            }catch {
              print("Error \(error)")
            }
        } else {
            do{
              try realm.write{
                  result[0].star = false
              }
            }catch {
              print("Error \(error)")
            }
        }
    }
}
