//
//  SettingDetailViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit
import PKHUD

class SettingDetailViewController: UIViewController {

    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private let appDelegateWindow = UIApplication.shared.windows.first

    private var timeArray: [String] = [] {
        didSet {
            settingDetailView.timePickerView.reloadAllComponents()
        }
    }
    
    var selectCell: String = ""
    var user: User?
    
    private var currentValue: String = "" {
        didSet {
            settingDetailView.valueLabel.text = currentValue
        }
    }
    
    let settingDetailView = SettingDetailView()
    
    var settingDetailModel: SettingDetailModel? {
        didSet {
            registerModel()
        }
    }
    
    var currentSubscriptionMode: Bool = false {
        
        didSet {
            self.settingDetailView.subscriptionSelect = currentSubscriptionMode
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.modeColor
        navigationItem.title = "\(selectCell)"
        
        self.settingDetailModel = SettingDetailModel()
        
        settingDetailModel?.setupTimeLayout()
        settingDetailModel?.confirmUserData()
        
        view.addSubview(settingDetailView)
    }
    
    override func viewDidLayoutSubviews() {

        settingDetailView.frame = view.frame
    }
    
    private func registerModel() {
        
        guard let model = settingDetailModel else { return }
        
        setupNotificationCenter(model: model)
        
        settingDetailView.confirmSelectCell(selectCell: self.selectCell)
        settingDetailView.letterSlider.addTarget(self, action: #selector(onStartPointlabel(_:)), for: .valueChanged)
        settingDetailView.modeSwitch.addTarget(self, action: #selector(modeChange), for: UIControl.Event.valueChanged)
        settingDetailView.tableCategorySwitch.addTarget(self, action: #selector(tableChange(sender:)), for: UIControl.Event.valueChanged)
        settingDetailView.subscriptSwitch.addTarget(self, action: #selector(subscriptionChange(sender:)), for: UIControl.Event.valueChanged)
        settingDetailView.timePickerView.delegate = self
        settingDetailView.timePickerView.dataSource = self
    }
    
    private func setupNotificationCenter(model: SettingDetailModel) {
        
        model.notificationCenter.addObserver(forName: .init(rawValue: SettingDetailModel.timeArrayNotificationName), object: nil, queue: nil) { notification in
            self.timeArray = notification.userInfo?["timeArray"] as! [String]
        }
        
        model.notificationCenter.addObserver(forName: .init(rawValue: SettingDetailModel.userNotificationName), object: nil, queue: nil) { notification in
            self.user = notification.userInfo?["user"] as? User
            self.settingDetailView.user = self.user
            self.settingDetailView.subscriptionSelect = self.user!.subscription
        }
    }

    @objc func modeChange(sender: UISwitch) {
        
        if #available(iOS 13.0, *) {
            
            let onCheck: Bool = sender.isOn
            if onCheck {
                appDelegateWindow?.overrideUserInterfaceStyle = .dark
                settingDetailView.modeSelect = true
            } else {
                appDelegateWindow?.overrideUserInterfaceStyle = .light
                settingDetailView.modeSelect = false
            }
        }
    }
    
    @objc func subscriptionChange(sender: UISwitch) {
        
        let onCheck: Bool = sender.isOn
        
        if onCheck {
            appDelegate.subscription = true
            HUD.show(.progress, onView: self.settingDetailView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: {
                self.currentSubscriptionMode = true
                HUD.hide()
            })
        } else {
            appDelegate.subscription = false
            HUD.show(.progress, onView: self.settingDetailView)
            DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: {
                self.currentSubscriptionMode = false
                HUD.hide()
            })
        }
    }
    
    @objc func tableChange(sender: UISwitch) {
        
        let onCheck: Bool = sender.isOn
        
        if onCheck {
            appDelegate.cellType = .Grid
            settingDetailView.tableSelect = true
        } else {
            appDelegate.cellType = .List
            settingDetailView.tableSelect = false
        }
    }
    
    @objc func onStartPointlabel(_ sender:UISlider!) {
        
        appDelegate.letterSize = Int(sender.value)
        currentValue = String(String(sender.value).prefix(2))
    }
}

extension SettingDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        appDelegate.interbalTime = Double(timeArray[row])!
        settingDetailView.timeLabelText = appDelegate.interbalTime
    }
}
