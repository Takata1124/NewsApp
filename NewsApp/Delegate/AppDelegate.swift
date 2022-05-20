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
    
    var appDelegateModel: AppDelegateModel? {
        
        didSet {
            registerModel()
        }
    }
    
    var subscription: Bool = false {
        didSet {
            appDelegateModel?.saveUserSubscription(subscription: self.subscription)
        }
    }
    
    var interbalTime: Double = 1 {
        didSet {
            appDelegateModel?.saveUserInterbalTime(interbalTime: interbalTime)
        }
    }
    
    var storedFeedItems: [FeedItem] = []
    var navigationController: UINavigationController?
    let unuserNotificationCenter = UNUserNotificationCenter.current()
    
    var realm: Realm?
    var window: UIWindow?
    
    func application(_ : UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().tintColor = UIColor.modeTextColor
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.modeTextColor]
        
        LoginManager.shared.setup(channelID: "1657027285", universalLinkURL: nil)
 
        self.realmMigration()
        
        self.appDelegateModel = AppDelegateModel()
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.MeasurementSample.refresh", using: nil) { task in
            self.appDelegateModel?.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func registerModel() {
        
        if let model = appDelegateModel {
            
            model.notificationCenter.addObserver(forName: .init(rawValue: AppDelegateModel.notificationSubscriptionName), object: nil, queue: nil) { notification in
                
                if let subscription = notification.userInfo?["subscription"] as? Bool {
                    self.subscription = subscription
                }
            }
            
            model.notificationCenter.addObserver(forName: .init(rawValue: AppDelegateModel.notificationInterbalTimeName), object: nil, queue: nil) { notification in
                
                if let interbalTime = notification.userInfo?["interbalTime"] as? Double {
                    self.interbalTime = interbalTime
                }
            }
            
            model.notificationCenter.addObserver(forName: .init(rawValue: AppDelegateModel.notificationAlertName), object: nil, queue: nil) { notification in
                if let alert = notification.userInfo?["alert"] as? Bool {
                    
                    if alert {
                        self.notificationAlert()
                    }
                }
            }
        }
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
    
    func notificationAlert() {
        
        if #available (iOS 10.0, *) {
            
            self.unuserNotificationCenter.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: {
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
        
        self.unuserNotificationCenter.getNotificationSettings { settings in
            
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
                    self.unuserNotificationCenter.delegate = self
                    
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
}
