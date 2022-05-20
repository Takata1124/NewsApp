//
//  AppDelegateModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/05/20.
//

import Foundation
import RealmSwift
import BackgroundTasks



class AppDelegateModel {
    
    var userDefaults: UserDefaults?
    var realm: Realm?
    
    let notificationCenter = NotificationCenter()
    static let notificationSubscriptionName = "SubscriptionData"
    static let notificationInterbalTimeName = "InterbalTimeData"
    static let notificationAlertName = "AlertData"
    
    var subscription: Bool = false {
        didSet {
            notificationCenter.post(name: .init(rawValue: AppDelegateModel.notificationSubscriptionName), object: nil, userInfo: ["subscription" : self.subscription])
            
            if subscription == false {
                BGTaskScheduler.shared.cancelAllTaskRequests()
            }
        }
    }
    
    var interbalTime: Double = 1.0 {
        didSet {
            notificationCenter.post(name: .init(rawValue: AppDelegateModel.notificationInterbalTimeName), object: nil, userInfo: ["interbalTime" : interbalTime])
        }
    }
    
    var isNotificationAlert: Bool = false {
        didSet {
            notificationCenter.post(name: .init(rawValue: AppDelegateModel.notificationAlertName), object: nil, userInfo: ["alert" : isNotificationAlert])
        }
    }
   
    init(userDefaults: UserDefaults = UserDefaults.standard, realm: Realm = try! Realm()) {
        
        self.userDefaults = userDefaults
        self.realm = realm
        
        setupUserSubscriptionAndInterbalTime()
        
        if subscription {

            BGTaskScheduler.shared.getPendingTaskRequests { requests in
                if requests == [] {
                    self.setupScheduleAppRefresh()
                }
            }
        }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        
        setupScheduleAppRefresh()
        
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
    
    func saveUserSubscription(subscription: Bool) {
        
        if let data: Data = userDefaults?.value(forKey: "User") as? Data {
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            let recodeUser: User = User(id: user.id, password: user.password, feed: user.feed, login: user.login, accessTokeValue: user.accessTokeValue, subscription: subscription, subsciptInterval: user.subsciptInterval)
            
            if let data: Data = try? JSONEncoder().encode(recodeUser) {
                userDefaults?.set(data, forKey: "User")
            }
        }
    }
    
    func saveUserInterbalTime(interbalTime: Double) {
        
        if let data: Data = userDefaults?.value(forKey: "User") as? Data {
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            let recodeUser: User = User(id: user.id, password: user.password, feed: user.feed, login: user.login, accessTokeValue: user.accessTokeValue, subscription: user.subscription, subsciptInterval: interbalTime)
            if let data: Data = try? JSONEncoder().encode(recodeUser) {
                userDefaults?.set(data, forKey: "User")
            }
        }
    }
    
    func setupUserSubscriptionAndInterbalTime() {
        
        if let data: Data = userDefaults?.value(forKey: "User") as? Data {
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            self.subscription = user.subscription
            self.interbalTime = user.subsciptInterval
        }
    }
    
    func setupScheduleAppRefresh() {
        
        if let data: Data = userDefaults?.value(forKey: "User") as? Data {
            
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            self.subscription = user.subscription
            self.interbalTime = user.subsciptInterval
            
            let request = BGAppRefreshTaskRequest(identifier: "com.MeasurementSample.refresh")
            
            request.earliestBeginDate = Date(timeIntervalSinceNow: self.interbalTime * 60)
            
            do {
                try BGTaskScheduler.shared.submit(request)
                compareStoreAlert()
            } catch {
                print("Could not schedule app refresh: \(error)")
            }
        }
    }
    
    func compareStoreAlert() {

        if let storedFeedItemsData = userDefaults?.data(forKey: "StoreFeedItems") {
        
            let storedFeedItems = try? JSONDecoder().decode([FeedItem].self, from: storedFeedItemsData)
            var tempRealmFeedItem: [FeedItem] = []
            let realmFeedItems = realm?.objects(RealmFeedItem.self)
            
            realmFeedItems?.forEach { item in
                if !item.title.contains("Yahoo!ニュース・トピックス") && item.title != "" {
                    
                    let feeditem = FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead)
                    
                    tempRealmFeedItem.append(feeditem)
                }
            }
            
            storedFeedItems?.forEach({ storeItem in

                if tempRealmFeedItem.contains(where: { realmItem in
                    realmItem.title == storeItem.title
                }) {
                    return
                } else {
                    self.isNotificationAlert = true
                }
            })
        }
    }
}
