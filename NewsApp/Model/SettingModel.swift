//
//  SettingModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/14.
//

import Foundation
import RealmSwift

class SettingModel {
    
    static let shared = SettingModel()
    static let notificationName = "SettingNotification"
    let notificationCenter = NotificationCenter()
    let userDefaults = UserDefaults.standard
    let realm = try! Realm()
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate

    static let settingList = ["ユーザー情報", "一覧画面表示切り替え","RSS取得間隔","購読RSS管理","文字サイズの変更","ダークモード","記事データの削除","購読データの削除","ログアウト"]

    func UserLogout(completion: @escaping(Bool) -> Void) {
        
        userDefaults.setValue(false, forKey: "userLogin")
        
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            let recodeUser: User = User(id: user.id, password: user.password, feed: user.feed, login: false, accessTokeValue: user.accessTokeValue, subscription: user.subscription, subsciptInterval: user.subsciptInterval)
            if let data: Data = try? JSONEncoder().encode(recodeUser) {
                userDefaults.set(data, forKey: "User")
                completion(true)
            }
        }
    }
    
    func deleteArticleData(completion: @escaping() -> Void) {
        
        let results = realm.objects(RealmFeedItem.self)
        try! realm.write {
            realm.delete(results)
            completion()
        }
    }
    
    func deleteSubscriptionData(completion: @escaping() -> Void) {
        
        appDelegate.storeFeedItems = []
        userDefaults.removeObject(forKey: "StoreFeedItems")
    }
}
