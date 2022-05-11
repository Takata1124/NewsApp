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
    let userDefaults: UserDefaults
    var realm: Realm
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let settingList = ["ユーザー情報", "一覧画面表示切り替え","RSS取得間隔","購読RSS管理","文字サイズの変更","ダークモード","記事データの削除","購読データの削除","ログアウト"]
    
    init(userDefaults: UserDefaults = UserDefaults.standard, realm: Realm = try! Realm()) {
        self.userDefaults = userDefaults
        self.realm = realm
    }
    
    func UserLogout(completion: @escaping(Bool) -> Void) {
        
        userDefaults.setValue(false, forKey: "userLogin")
        completion(true)
    }
    
    func deleteArticleData(completion: @escaping() -> Void) {
        
        let results = realm.objects(RealmFeedItem.self)
        
        do {
            try realm.write {
                realm.delete(results)
                completion()
            }
        } catch {
            fatalError("エラーが発生")
        }
    }
    
    func deleteSubscriptionData(completion: @escaping() -> Void) {
        
        appDelegate.storeFeedItems = []
        userDefaults.removeObject(forKey: "StoreFeedItems")
        
        completion()
    }
}
