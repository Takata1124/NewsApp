//
//  RssModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/13.
//

import Foundation

class RssModel {
    
    let rssArray :[String] = ["主要","国内","国際","経済","エンタメ","スポーツ","IT","科学","地域"]
    
    static let shared = RssModel()
    static let notificationName = "RssErrerMessage"
    var userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = UserDefaults.standard ) {
        self.userDefaults = userDefaults
    }
    
    func saveUseData(id: String, password: String, accessTokeValue: String, indexPath :IndexPath, completion: @escaping(Bool) -> Void) {
        
        let selectFeed = rssArray[indexPath.row]
        
        let user = User(id: id, password: password, feed: selectFeed, login: true, accessTokeValue: accessTokeValue, subscription: false, subsciptInterval: 1.0)

        if let data: Data = try? JSONEncoder().encode(user) {
            
            self.userDefaults.setValue(true, forKey: "userLogin")
            self.userDefaults.setValue(data, forKey: "User")
            completion(true)
            
        } else {
            completion(false)
        }
    }
}
