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

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var letterSize: Int = 13
    var cellType: CellType = .List
    var InterbalTime: Double = 15
    let userdefaults = UserDefaults.standard
    var storeFeedItems: [FeedItem] = []
    var navigationController: UINavigationController?
    
    let usernotificationCenter = UNUserNotificationCenter.current()
    
    var realm: Realm?
    
    var window: UIWindow?
    
    func application(_ : UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = UIColor.modeTextColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.modeTextColor]
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.MeasurementSample.refresh", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.getPendingTaskRequests { requests in
            
            print(requests)
            if requests == [] {
                
                if var value: Int = self.userdefaults.value(forKey: "count") as? Int
                {
                    self.scheduleAppRefresh()
                } else {
                    self.userdefaults.set(0, forKey: "count")
                    self.scheduleAppRefresh()
                }
            }
        }
        
        print(userdefaults.object(forKey: "count") as Any)
        print(userdefaults.array(forKey: "date") as Any)
        
        migration()
        
        self.realm = try! Realm()
   
        let object = realm?.objects(StoreFeedItem.self)
        object?.forEach { item in
            self.storeFeedItems.append(FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: false, read: false, afterRead: false))
        }
        
        let dt = Date()
        print(dt)

        return true
    }
    
    private func formatter(date: Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss Z"
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm Z"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([[.banner, .sound]])
    }
    
    private func migration() {
        
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
        let operation = getXMLDataOperation()
        
        operationQueue.maxConcurrentOperationCount = 1
        
        task.expirationHandler = {
            operationQueue.cancelAllOperations()
        }
        
        operation.completionBlock = {
            task.setTaskCompleted(success: !operation.isCancelled)
        }
        
        operationQueue.addOperation(operation)
    }
    
    private func scheduleAppRefresh() {
        
        let request = BGAppRefreshTaskRequest(identifier: "com.MeasurementSample.refresh")
        
        request.earliestBeginDate = Date(timeIntervalSinceNow: InterbalTime * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    private func showingAlert() {

        var isContain: Bool = false
        var tempStoreFeedTitle: [String] = []
        var tempRealmFeedTitle: [String] = []
        
        let storeObject = realm?.objects(StoreFeedItem.self)
        storeObject?.forEach { item in
            tempStoreFeedTitle.append(item.title)
        }
        
        let realmObject = realm?.objects(RealmFeedItem.self)
        realmObject?.forEach { item in
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
