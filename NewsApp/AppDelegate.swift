//
//  AppDelegate.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/01.
//

import UIKit
import AuthenticationServices
import BackgroundTasks
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var letterSize: Int = 13
    var cellType: CellType = .List
    var InterbalTime: Double = 60
    let userdefaults = UserDefaults.standard
    var newDataAlert: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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
        
        let realm = try! Realm()
        let object = realm.objects(StoreFeedItem.self)
        print(object)
        
        let dt = Date()
        print(dt)
        
        return true
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
        
        print("taskの登録")
        
        let request = BGAppRefreshTaskRequest(identifier: "com.MeasurementSample.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: InterbalTime * 60)
        
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
}
