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
    
 
    static let settingList = ["一覧画面表示切り替え","RSS取得間隔","購読RSS管理","文字サイズの変更","ダークモード","記事データの削除","購読データの削除","ユーザー情報の削除","ログアウト"]

    func UserLogout() {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return }
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        let recodeUser: User = User(id: user.id, password: user.password, feed: user.feed, login: false)
        guard let data: Data = try? JSONEncoder().encode(recodeUser) else { return }
        userDefaults.set(data, forKey: "User")
    }
    
    func removeUser() {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return }
        userDefaults.removeObject(forKey: "User")
    }
    
    func deleteArticleData(completion: @escaping() -> Void) {
        
        let results = realm.objects(RealmFeedItem.self)
        try! realm.write {
            realm.delete(results)
            completion()
        }
    }
    
    func deleteSubscriptionData(completion: @escaping() -> Void) {
        
        let results = realm.objects(StoreFeedItem.self)
        try! realm.write {
            realm.delete(results)
            completion()
        }
    }
}
