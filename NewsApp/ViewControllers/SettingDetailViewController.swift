//
//  SettingDetailViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class SettingDetailViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private let appDelegateWindow = UIApplication.shared.windows.first
    
    private var timeArray: [String] = []
    
    var selectCell: String = ""
    
    let letterSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x:0, y:0, width:350, height:30))
        slider.backgroundColor = UIColor.white
        slider.layer.cornerRadius = 10.0
        slider.layer.masksToBounds = false
        slider.minimumValue = 10
        slider.maximumValue = 20
        slider.addTarget(self, action: #selector(onStartPointlabel(_:)), for: .valueChanged)
        return slider
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 300, width: 100, height: 50))
        label.textAlignment = .center
        return label
    }()
    
    let modeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 300, width: 100, height: 50))
        label.textAlignment = .center
        return label
    }()
    
    let modeSwitch: UISwitch = {
        let uiswitch = UISwitch(frame: CGRect(x: 0, y: 0 , width: 49, height: 31))
        uiswitch.addTarget(self, action: #selector(modeChange), for: UIControl.Event.valueChanged)
        return uiswitch
    }()
    
    let tableSwitch: UISwitch = {
        let tableswitch = UISwitch(frame: CGRect(x: 0, y: 0 , width: 49, height: 31))
        tableswitch.addTarget(self, action: #selector(tableChange(sender:)), for: UIControl.Event.valueChanged)
        return tableswitch
    }()
    
    var tableCategory: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: 300, width: 300, height: 50))
        label.text = "TableView"
        label.textAlignment = .center
        return label
    }()
    
    var subscriptSwitch: UISwitch = {
        let uiswitch = UISwitch(frame: CGRect(x: 0, y: 0 , width: 49, height: 31))
        uiswitch.addTarget(self, action: #selector(subscriptionChange(sender:)), for: UIControl.Event.valueChanged)
        return uiswitch
    }()
    
    var subscriptLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: 300, width: 300, height: 50))
        label.text = "Off"
        label.textAlignment = .center
        return label
    }()
    
    let timePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.layer.borderWidth = 1.0
        pickerView.layer.borderColor = UIColor.modeTextColor.cgColor
        pickerView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        return pickerView
    }()
    
    private var currentValue: String = "" {
        
        didSet {
            valueLabel.text = currentValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.modeColor
        navigationItem.title = "\(selectCell)"
        
        setupTimeLayout()
        
        timePickerView.delegate = self
        timePickerView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        
        selectCategorySetting(selectCell: self.selectCell)
    }

    private func setupTimeLayout() {
        
        for i in 0..<25 {
            
            let i: String = "\(i)"
            timeArray.append(i)
        }
        
        timeArray.append("48")
        timeArray.append("72")
    }
    
    private func selectCategorySetting(selectCell: String) {
        
        switch selectCell {
            
        case "一覧画面表示切り替え":
            tableswitchLayout()
            
        case "RSS取得間隔":
            timeArraySetupLayout()
            
        case "購読RSS管理":
            subscriptSetupLayout()
            
        case "文字サイズの変更":
            sliderLayout()
            
        case "ダークモード":
            modeSetupLayout()
            
        default:
            print("default")
        }
    }
    
    private func subscriptSetupLayout() {
        
        view.addSubview(subscriptLabel)
        view.addSubview(subscriptSwitch)
        
        subscriptSwitch.center = view.center
    }
    
    private func timeArraySetupLayout() {
        
        view.addSubview(timePickerView)
        
        timePickerView.center = view.center
    }
    
    private func modeSetupLayout() {
        
        view.addSubview(modeLabel)
        view.addSubview(modeSwitch)
        
        modeSwitch.center = view.center
        
        if appDelegateWindow?.overrideUserInterfaceStyle == .dark {
            modeSwitch.isOn = true
            modeLabel.text = "dark"
        } else {
            modeSwitch.isOn = false
            modeLabel.text = "light"
        }
    }
    
    private func sliderLayout() {
        
        view.addSubview(letterSlider)
        view.addSubview(valueLabel)
        
        letterSlider.value = Float(appDelegate.letterSize)
        letterSlider.center = view.center
        
        valueLabel.text = String(appDelegate.letterSize)
    }
    
    private func tableswitchLayout() {
        
        view.addSubview(tableSwitch)
        view.addSubview(tableCategory)
        
        if appDelegate.cellType == .Grid {
            tableSwitch.isOn = true
            tableCategory.text = "CollectionView"
        } else {
            tableSwitch.isOn = false
            tableCategory.text = "TableView"
        }
        
        tableSwitch.center = view.center
    }
    
    @objc func modeChange(sender: UISwitch) {
        
        if #available(iOS 13.0, *) {
            
            let onCheck: Bool = sender.isOn
            
            if onCheck {
                appDelegateWindow?.overrideUserInterfaceStyle = .dark
            } else {
                appDelegateWindow?.overrideUserInterfaceStyle = .light
            }
        }
    }
    
    @objc func subscriptionChange(sender: UISwitch) {
        
        let onCheck: Bool = sender.isOn
        
        if onCheck {
            subscriptLabel.text = "On"
        } else {
            subscriptLabel.text = "Off"
        }
    }
    
    @objc func tableChange(sender: UISwitch) {
        
        let onCheck: Bool = sender.isOn
        
        if onCheck {
            appDelegate.cellType = .Grid
            tableCategory.text = "CollectionView"
        } else {
            appDelegate.cellType = .List
            tableCategory.text = "TableView"
        }
    }
    
    @objc func onStartPointlabel(_ sender:UISlider!) {
        
        appDelegate.letterSize = Int(sender.value)
        currentValue = String(String(sender.value).prefix(2))
    }
    
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


