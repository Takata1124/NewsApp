//
//  SettingDetailViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class SettingDetailViewController: UIViewController {
    
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    let appDelegateWindow = UIApplication.shared.windows.first
    
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
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.width / 2, y: 100, width: 100, height: 50))
        label.backgroundColor = .white
        return label
    }()
    
    let uiswitch: UISwitch = {
        let uiswitch = UISwitch(frame: CGRect(x: 0, y: 0 , width: 49, height: 31))
        uiswitch.addTarget(self, action: #selector(changeSwitch), for: UIControl.Event.valueChanged)
        return uiswitch
    }()
    
    private var currentValue: String = "" {
        
        didSet {
            valueLabel.text = currentValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.modeColor
        
        view.addSubview(letterSlider)
        view.addSubview(valueLabel)
        //        view.addSubview(uiswitch)
    }
    
    override func viewDidLayoutSubviews() {
        
        letterSlider.value = Float(appDelegate.letterSize)
        letterSlider.center = view.center
        
        valueLabel.text = String(appDelegate.letterSize)
        
        //        uiswitchLayout()
    }
    
    private func uiswitchLayout() {
        
        uiswitch.center = view.center
        
        if appDelegateWindow?.overrideUserInterfaceStyle == .dark {
            uiswitch.isOn = true
        } else {
            uiswitch.isOn = false
        }
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
    
    @objc func onStartPointlabel(_ sender:UISlider!) {
        
        //        print(sender.value)
        appDelegate.letterSize = Int(sender.value)
        currentValue = String(String(sender.value).prefix(2))
    }
}


