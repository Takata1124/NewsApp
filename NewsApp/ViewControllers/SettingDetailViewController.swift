//
//  SettingDetailViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class SettingDetailViewController: UIViewController {

    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private let appDelegateWindow = UIApplication.shared.windows.first
    private var timeArray: [String] = []
    
    var selectCell: String = ""
    
    private var currentValue: String = "" {
        didSet {
            settingDetailView.valueLabel.text = currentValue
        }
    }
    
    let settingDetailView = SettingDetailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.modeColor
        navigationItem.title = "\(selectCell)"
        
        setupTimeLayout()
        
        settingDetailView.confirmSelectCell(selectCell: selectCell)
        settingDetailView.letterSlider.addTarget(self, action: #selector(onStartPointlabel(_:)), for: .valueChanged)
        settingDetailView.modeSwitch.addTarget(self, action: #selector(modeChange), for: UIControl.Event.valueChanged)
        settingDetailView.tableSwitch.addTarget(self, action: #selector(tableChange(sender:)), for: UIControl.Event.valueChanged)
        settingDetailView.subscriptSwitch.addTarget(self, action: #selector(subscriptionChange(sender:)), for: UIControl.Event.valueChanged)
        
        view.addSubview(settingDetailView)
    }
    
    override func viewDidLayoutSubviews() {

        settingDetailView.frame = view.frame
    }

    private func setupTimeLayout() {
        
        for i in 0..<25 {
            let i: String = "\(i)"
            timeArray.append(i)
        }
    }
    
    @objc func modeChange(sender: UISwitch) {
        
        if #available(iOS 13.0, *) {
            
            let onCheck: Bool = sender.isOn
            if onCheck {
                appDelegateWindow?.overrideUserInterfaceStyle = .dark
                settingDetailView.modeLabel.text = "dark"
            } else {
                appDelegateWindow?.overrideUserInterfaceStyle = .light
                settingDetailView.modeLabel.text = "light"
            }
        }
    }
    
    @objc func subscriptionChange(sender: UISwitch) {
        
        let onCheck: Bool = sender.isOn
        
        if onCheck {
            settingDetailView.subscriptLabel.text = "On"
        } else {
            settingDetailView.subscriptLabel.text = "Off"
        }
    }
    
    @objc func tableChange(sender: UISwitch) {
        
        let onCheck: Bool = sender.isOn
        
        if onCheck {
            appDelegate.cellType = .Grid
            settingDetailView.tableCategory.text = "CollectionView"
        } else {
            appDelegate.cellType = .List
            settingDetailView.tableCategory.text = "TableView"
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
        print(timeArray[row])
    }
}


