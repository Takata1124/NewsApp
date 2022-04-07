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
    
    let uiswitch: UISwitch = {
        let uiswitch = UISwitch(frame: CGRect(x: 0, y: 0 , width: 49, height: 31))
        uiswitch.addTarget(self, action: #selector(changeSwitch), for: UIControl.Event.valueChanged)
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
    
    private var currentValue: String = "" {
        
        didSet {
            valueLabel.text = currentValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.modeColor
    }
    
    override func viewDidLayoutSubviews() {
        
        selectCategorySetting(selectCell: self.selectCell)
    }
    
    private func selectCategorySetting(selectCell: String) {
        
        switch selectCell {
            
        case "一覧画面表示切り替え":
            tableswitchLayout()
            
        case "RSS取得間隔":
            print("RSS取得間隔")
            
        case "購読RSS管理":
            print("購読RSS管理")
            
        case "文字サイズの変更":
            uisliderLayout()
            
        case "ダークモード":
            uiswitchLayout()
            
        default:
            print("default")
        }
    }
    
    private func uiswitchLayout() {
        
        view.addSubview(modeLabel)
        view.addSubview(uiswitch)
        
        uiswitch.center = view.center
        
        if appDelegateWindow?.overrideUserInterfaceStyle == .dark {
            uiswitch.isOn = true
            modeLabel.text = "dark"
        } else {
            uiswitch.isOn = false
            modeLabel.text = "light"
        }
    }
    
    private func uisliderLayout() {
        
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
    
    @objc func changeSwitch(sender: UISwitch) {
        
        if #available(iOS 13.0, *) {
            
            let onCheck: Bool = sender.isOn
            
            if onCheck {
                appDelegateWindow?.overrideUserInterfaceStyle = .dark
            } else {
                appDelegateWindow?.overrideUserInterfaceStyle = .light
            }
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
}


