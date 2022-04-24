//
//  SettingDetailView.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/11.
//

import UIKit

class SettingDetailView: UIView {
    
    var selectCell: String = "" {
        didSet {
            selectCategorySetting(selectCell: selectCell)
        }
    }
    
    var subscriptionSelect: Bool = false {
        didSet {
            if subscriptionSelect {
                subscriptLabel.text = "ON"
                subscriptSwitch.isOn = true
            } else {
                subscriptLabel.text = "OFF"
                subscriptSwitch.isOn = false
            }
        }
    }
    
    var modeSelect: Bool = false {
        didSet {
            if modeSelect {
                modeLabel.text = "dark"
                modeSwitch.isOn = true
            } else {
                modeLabel.text = "light"
                modeSwitch.isOn = false
            }
        }
    }
    
    var tableSelect: Bool = false {
        didSet {
            if tableSelect {
                tableSwitch.isOn = true
                tableCategory.text = "CollectionView"
            } else {
                tableSwitch.isOn = false
                tableCategory.text = "TableView"
            }
        }
    }
    
    var timeLabelText: Double = 1 {
        
        didSet {
            timeLabel.text = "現在の取得時間は\(timeLabelText)時間です"
        }
    }
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private let appDelegateWindow = UIApplication.shared.windows.first
    
    let letterSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 175, y: UIScreen.main.bounds.height / 2, width:350, height:30))
        slider.backgroundColor = UIColor.white
        slider.layer.cornerRadius = 10.0
        slider.layer.masksToBounds = false
        slider.minimumValue = 10
        slider.maximumValue = 20

        return slider
    }()
    
    let valueLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 300, width: 100, height: 50))
        label.textAlignment = .center
        return label
    }()
    
    var modeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 300, width: 100, height: 50))
        label.textAlignment = .center
        return label
    }()
    
    let modeSwitch: UISwitch = {
        let uiswitch = UISwitch(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2, width: 50, height: 31))
        return uiswitch
    }()
    
    let tableSwitch: UISwitch = {
        let tableswitch = UISwitch(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2, width: 50, height: 31))
        return tableswitch
    }()
    
    var tableCategory: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: 300, width: 300, height: 50))
        label.textAlignment = .center
        return label
    }()
    
    var subscriptSwitch: UISwitch = {
        let uiswitch = UISwitch(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2, width: 50, height: 31))
        return uiswitch
    }()
    
    var subscriptLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: 300, width: 300, height: 50))
        label.textAlignment = .center
        return label
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: 150, width: 300, height: 50))
        label.textAlignment = .center
        return label
    }()
    
    let timePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.layer.borderWidth = 1.0
        pickerView.layer.borderColor = UIColor.modeTextColor.cgColor
        pickerView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height / 2 - 100, width: 200, height: 200)
        return pickerView
    }()
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        selectCategorySetting(selectCell: selectCell)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func confirmSelectCell(selectCell: String) {
        
        self.selectCell = selectCell
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
    
    private func tableswitchLayout() {
        
        self.addSubview(tableSwitch)
        self.addSubview(tableCategory)
        
        if appDelegate.cellType == .Grid {
            tableSelect = true
        } else {
            tableSelect = false
        }
    }
    
    private func timeArraySetupLayout() {
        
        self.addSubview(timePickerView)
        self.addSubview(timeLabel)
        
        timeLabel.text = "現在の取得時間は\(appDelegate.InterbalTime)時間です"
    }
    
    private func subscriptSetupLayout() {
        
        self.addSubview(subscriptLabel)
        self.addSubview(subscriptSwitch)
        
        if appDelegate.subscription {
            subscriptionSelect = true
        } else {
            subscriptionSelect = false
        }
    }

    private func sliderLayout() {
        
        self.addSubview(letterSlider)
        self.addSubview(valueLabel)
        
        letterSlider.value = Float(appDelegate.letterSize)
        valueLabel.text = String(appDelegate.letterSize)
    }
    
    private func modeSetupLayout() {
        
        self.addSubview(modeLabel)
        self.addSubview(modeSwitch)
        
        if appDelegateWindow?.overrideUserInterfaceStyle == .dark {
            modeSelect = true
        } else {
            modeSelect = false
        }
    }
}
