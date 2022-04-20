//
//  AlertOperation.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/20.
//

import Foundation
import RealmSwift

class AlertOperation: Operation, UNUserNotificationCenterDelegate {
    
    var isContain: Bool = false
    var tempStoreFeedTitle: [String] = []
    var tempRealmFeedTitle: [String] = []
    
    let realm = try! Realm()
    
    var window: UIWindow?
    
    let usernotificationCenter = UNUserNotificationCenter.current()
    
    override func main() {
        
        let storeObject = realm.objects(StoreFeedItem.self)
        storeObject.forEach { item in
            tempStoreFeedTitle.append(item.title)
        }
        
        let realmObject = realm.objects(RealmFeedItem.self)
        realmObject.forEach { item in
            tempRealmFeedTitle.append(item.title)
        }
        
        tempStoreFeedTitle.forEach { storeTitle in
            if tempRealmFeedTitle.contains(storeTitle) {
                isContain = true
            }
        }
        
        if isContain { return }

        if #available (iOS 10.0, *) {
           
            usernotificationCenter.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: {
                (granted, error) in
                
                DispatchQueue.main.async {
                    if granted == true {
                        UIApplication.shared.registerForRemoteNotifications()
                    } else {
                        print("permisson Denied")
                    }
                }
            })
        }
        
        usernotificationCenter.getNotificationSettings { settings in
            
            DispatchQueue.main.async {
                
                let title = "NewsApp"
                let message = "更新データがあります"
                let date = Date(timeIntervalSinceNow: 1 * 30)
                
                if settings.authorizationStatus == .authorized {
                    
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    content.badge = 1
                    
                    let dateComp = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComp, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    self.usernotificationCenter.delegate = self
                    
                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    
                } else {
                    
                    let ac = UIAlertController(title: "プッシュ通知が使用できません", message: "設定画面よりアプリのプッシュ通知をONにしてください", preferredStyle: .alert)
                    let goToSettings = UIAlertAction(title: title, style: .default) { _ in
                        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                        
                        if UIApplication.shared.canOpenURL(settingsURL) {
                            UIApplication.shared.open(settingsURL) { _ in }
                        }
                       
                    }
                    ac.addAction(goToSettings)
                    ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { _ in }))
                    self.window?.rootViewController?.present(ac, animated: true, completion: nil)
                }
            }
        }
    }
}
