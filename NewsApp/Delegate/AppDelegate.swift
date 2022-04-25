//
//  AppDelegate.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/01.
//

import UIKit
import BackgroundTasks
import RealmSwift
import UserNotifications
import LineSDK

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var letterSize: Int = 13
    var cellType: CellType = .List
    
    var subscription: Bool = false {
        didSet {
            guard let data: Data = userdefaults.value(forKey: "User") as? Data else { return }
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            let recodeUser: User = User(id: user.id, password: user.password, feed: user.feed, login: user.login, accessTokeValue: user.accessTokeValue, subscription: self.subscription, subsciptInterval: user.subsciptInterval)
            guard let data: Data = try? JSONEncoder().encode(recodeUser) else { return }
            userdefaults.set(data, forKey: "User")
            
            if subscription == false {
                BGTaskScheduler.shared.cancelAllTaskRequests()
            }
        }
    }
    
    var InterbalTime: Double = 1 {
        didSet {
            guard let data: Data = userdefaults.value(forKey: "User") as? Data else { return }
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            let recodeUser: User = User(id: user.id, password: user.password, feed: user.feed, login: user.login, accessTokeValue: user.accessTokeValue, subscription: user.subscription, subsciptInterval: self.InterbalTime)
            guard let data: Data = try? JSONEncoder().encode(recodeUser) else { return }
            userdefaults.set(data, forKey: "User")
        }
    }
    
    let userdefaults = UserDefaults.standard
    var storeFeedItems: [FeedItem] = []
    var navigationController: UINavigationController?
    
    let usernotificationCenter = UNUserNotificationCenter.current()
    
    var realm: Realm?
    var window: UIWindow?
    
    func application(_ : UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = UIColor.modeTextColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.modeTextColor]
        //LineSetup
        LoginManager.shared.setup(channelID: "1657027285", universalLinkURL: nil)
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.MeasurementSample.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        DispatchQueue.main.async {
            
            self.realmMigration()
            self.realm = try! Realm()
        }
        
        if let data: Data = userdefaults.value(forKey: "User") as? Data {
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            self.subscription = user.subscription
            self.InterbalTime = user.subsciptInterval
        }
        //購読設定なしでリターン
        if !subscription { return true }
        
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            
            print(requests)
            if requests == [] {
                self.scheduleAppRefresh()
            }
        }
        
        print(userdefaults.object(forKey: "date") as Any)
        
        let jsonDecoder = JSONDecoder()
        guard let data = userdefaults.data(forKey: "StoreFeedItems") else { return true }
        let store = try? jsonDecoder.decode([FeedItem].self, from: data)
        
        store?.forEach({ item in
            storeFeedItems.append(item)
        })
        
        print(storeFeedItems)
      
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //        completionHandler([[.banner, .sound]])
    }
    
    private func realmMigration() {
        
        let nextSchemaVersion = 2
        
        let config = Realm.Configuration(
            schemaVersion: UInt64(nextSchemaVersion),
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < nextSchemaVersion) {
                }
            })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    private func notificationAlert() {
        
        if #available (iOS 10.0, *) {
            
            self.usernotificationCenter.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: {
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
        
        self.usernotificationCenter.getNotificationSettings { settings in
            
            DispatchQueue.main.async {
                
                let title = "NewsApp"
                let message = "更新データがあります"
                
                if settings.authorizationStatus == .authorized {
                    
                    let content = UNMutableNotificationContent()
                    content.title = title
                    content.body = message
                    content.badge = 1
                    content.sound = UNNotificationSound.default
                    
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
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
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        
        print("Call to task")
        
        scheduleAppRefresh()
  
        if var dateArray = self.userdefaults.value(forKey: "date") as? [Date] {
            let nowDay = Date()
            var tempArray = userdefaults.array(forKey: "date")
            tempArray?.append(nowDay)
            self.userdefaults.set(tempArray, forKey: "date")
        } else {
            let nowDay = Date()
            var dtArray: [Date] = []
            dtArray.append(nowDay)
            self.userdefaults.set(dtArray, forKey: "date")
        }
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        let operation = getXMLDataOperation()
        
        task.expirationHandler = {
            operationQueue.cancelAllOperations()
        }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        operationQueue.addOperation(operation)
    }
    
    func scheduleAppRefresh() {
        
        if let data: Data = userdefaults.value(forKey: "User") as? Data {
            
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            self.subscription = user.subscription
            self.InterbalTime = user.subsciptInterval
            
            let request = BGAppRefreshTaskRequest(identifier: "com.MeasurementSample.refresh")
            
            request.earliestBeginDate = Date(timeIntervalSinceNow: self.InterbalTime * 3600)
            
            do {
                print("request")
                try BGTaskScheduler.shared.submit(request)
                compareStoreAlert()
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
        }
    }
    
    private func compareStoreAlert() {
        
        var notContain: Bool = false
        let jsonDecoder = JSONDecoder()
        guard let data = userdefaults.data(forKey: "StoreFeedItems") else { return }
        let store = try? jsonDecoder.decode([FeedItem].self, from: data)
        
        self.realmMigration()
        self.realm = try! Realm()
        
        var tempRealmFeedItem: [FeedItem] = []
        let result = realm?.objects(RealmFeedItem.self)
        
        result?.forEach { item in
            if !item.title.contains("Yahoo!ニュース・トピックス") {
                
                let feeditem = FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead)
                
                guard let title = feeditem.title else { return }
                
                if title != "" {
                    tempRealmFeedItem.append(feeditem)
                }
            }
        }
        
        store?.forEach({ storeItem in
            if tempRealmFeedItem.contains(where: { realmItem in
                realmItem.title == storeItem.title
            }) {
                print(storeItem.title ?? "")
                return
            } else {
                notContain = true
            }
        })
        
        if notContain {
            notificationAlert()
        }
    }
}
