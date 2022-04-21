//
//  RssModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/13.
//

import Foundation
import RealmSwift

class RssModel {
    
    let rssArray :[String] = ["主要","国内","国際","経済","エンタメ","スポーツ","IT","科学","地域"]
    
    static let shared = RssModel()
    static let notificationName = "RssErrerMessage"
    
    private let userDefaults = UserDefaults.standard
    let realm = try! Realm()
    
    init() {
        
    }
    
    func saveUseData(id: String, password: String, accessTokeValue: String, indexPath :IndexPath, completion: @escaping(Bool) -> Void) {
        
        let selectFeed = rssArray[indexPath.row]
        
        let user = User(id: id, password: password, feed: selectFeed, login: true, accessTokeValue: accessTokeValue)
        
        if let data: Data = try? JSONEncoder().encode(user){
            self.userDefaults.setValue(data, forKey: "User")
            
            let results = realm.objects(RealmFeedItem.self)
            let storeResults = realm.objects(StoreFeedItem.self)

            try! realm.write {
                realm.delete(results)
                realm.delete(storeResults)
                completion(true)
            }
        } else {
            completion(false)
            return
        }
    }
}
