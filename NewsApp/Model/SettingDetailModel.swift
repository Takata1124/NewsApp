//
//  SettingDetailModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/05/08.
//

import Foundation

class SettingDetailModel {
    
//    static let shared = SettingDetailModel()
    let notificationCenter = NotificationCenter()
    static let timeArrayNotificationName = "timeArrayNotificationName"
    static let userNotificationName = "userNotificationName"
    var userDefaults = UserDefaults.standard
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        self.userDefaults = userDefaults
    }
    
    var timeArray: [String] = [] {
        didSet {
            notificationCenter.post(name: .init(rawValue: SettingDetailModel.timeArrayNotificationName), object: nil, userInfo: ["timeArray": self.timeArray])
        }
    }
    
    func setupTimeLayout() {
        
        for i in 1..<25 {
            let i: String = "\(i)"
            timeArray.append(i)
        }
    }

    func confirmUserData() {
        
        if let data: Data = userDefaults.value(forKey: "User") as? Data {
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            
            notificationCenter.post(name: .init(rawValue: SettingDetailModel.userNotificationName), object: nil, userInfo: ["user": user])
        }
    }
}
