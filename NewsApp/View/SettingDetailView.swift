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
                tableCategorySwitch.isOn = true
                tableCategoryLabel.text = "CollectionView"
            } else {
                tableCategorySwitch.isOn = false
                tableCategoryLabel.text = "TableView"
            }
        }
    }
    
    var timeLabelText: Double = 1 {
        didSet {
            timeLabel.text = "現在の取得時間は\(timeLabelText)分です"
        }
    }
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private let appDelegateWindow = UIApplication.shared.windows.first
    
    var modeSwitch = BaseSwitch()
    var tableCategorySwitch = BaseSwitch()
    var subscriptSwitch = BaseSwitch()
    
    var tableCategoryLabel = BaseLabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: 300, width: 300, height: 50))
    var subscriptLabel = BaseLabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: 300, width: 300, height: 50))
    var timeLabel = BaseLabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 150, y: 150, width: 300, height: 50))
    var valueLabel = BaseLabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 300, width: 100, height: 50))
    var modeLabel = BaseLabel(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 50, y: 300, width: 100, height: 50))
    
    let letterSlider: UISlider = {
        
        let slider = UISlider(frame: CGRect(x: UIScreen.main.bounds.width / 2 - 175, y: UIScreen.main.bounds.height / 2, width:350, height:30))
        slider.backgroundColor = UIColor.white
        slider.layer.cornerRadius = 10.0
        slider.layer.masksToBounds = false
        slider.minimumValue = 10
        slider.maximumValue = 20
        
        return slider
    }()
    
    let timePickerView: UIPickerView = {
        
        let pickerView = UIPickerView()
        pickerView.layer.borderWidth = 1.0
        pickerView.layer.borderColor = UIColor.modeTextColor.cgColor
        pickerView.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 100, y: UIScreen.main.bounds.height / 2 - 100, width: 200, height: 200)
        return pickerView
    }()
    
    var userStackView: UIStackView?
    
    var idLabel = BaseLabel()
    var passwordLabel = BaseLabel()
    var feedLabel = BaseLabel()
    var loginLabel = BaseLabel()
    var subscriptionLabel = BaseLabel()
    var subscriptionIntervalLabel = BaseLabel()
    var accessTokenValueLabel = BaseLabel()
    
    var user: User? {
        didSet {
            DispatchQueue.main.async {
                self.idLabel.text = "idは\(String(describing: self.user!.id))"
                self.passwordLabel.text = "passwordは\(String(describing: self.user!.password))"
                self.feedLabel.text = "トピックは\(String(describing: self.user!.feed))"
                self.loginLabel.text = "Login状態は\(String(describing: self.user!.login.description))"
                self.subscriptionLabel.text = "購読状態は\(String(describing: self.user!.subscription.description))"
                self.subscriptionIntervalLabel.text = "購読間隔は\(String(describing: self.user!.subsciptInterval.description))分間です"
                self.accessTokenValueLabel.text = "アクセストークンは\(String(describing:self.user!.accessTokeValue))"
            }
        }
    }
    
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
            
        case "ユーザー情報":
            userInformationLayout()
            
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
    
    private func userInformationLayout() {
        
        self.userStackView = UIStackView()
        self.userStackView?.axis = .vertical
        self.userStackView?.alignment = .leading
        self.userStackView?.distribution = .fillEqually
        self.userStackView?.spacing = 10
        self.userStackView?.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.userStackView!)
        
        self.userStackView?.addArrangedSubview(idLabel)
        self.userStackView?.addArrangedSubview(passwordLabel)
        self.userStackView?.addArrangedSubview(feedLabel)
        self.userStackView?.addArrangedSubview(loginLabel)
        self.userStackView?.addArrangedSubview(subscriptionLabel)
        self.userStackView?.addArrangedSubview(subscriptionIntervalLabel)
        self.userStackView?.addArrangedSubview(accessTokenValueLabel)
        
        [self.userStackView?.centerXAnchor.constraint(equalTo: self.centerXAnchor),
         userStackView?.centerYAnchor.constraint(equalTo: self.centerYAnchor),
         userStackView?.widthAnchor.constraint(equalToConstant: 300),
         userStackView?.heightAnchor.constraint(equalToConstant: 300)
        ].forEach { $0?.isActive = true }
    }
    
    private func tableswitchLayout() {
        
        self.addSubview(tableCategorySwitch)
        self.addSubview(tableCategoryLabel)
        
        if appDelegate.cellType == .Grid {
            tableSelect = true
        } else {
            tableSelect = false
        }
    }
    
    private func timeArraySetupLayout() {
        
        self.addSubview(timePickerView)
        self.addSubview(timeLabel)
        
        timeLabel.text = "現在の取得時間は\(appDelegate.interbalTime)分間隔です"
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
