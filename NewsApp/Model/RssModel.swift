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
    
    private let userDefaults = UserDefaults.standard
    
    init() {
        
    }
    
    func saveUseData(id: String, password: String, indexPath :IndexPath, completion: @escaping(Bool) -> Void) {
        
        let selectFeed = rssArray[indexPath.row]
        
        let user = User(id: id, password: password, feed: selectFeed, login: true)
        
        if let data: Data = try? JSONEncoder().encode(user){
            self.userDefaults.setValue(data, forKey: "User")
            completion(true)
        } else {
            completion(false)
            return
        }
    }
}
