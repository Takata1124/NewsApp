//
//  SettingDetailViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class SettingDetailViewController: UIViewController {
    
    let appDelegate = UIApplication.shared.windows.first

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
    
    let uiswitch: UISwitch = {
        let uiswitch = UISwitch(frame: CGRect(x: 0, y: 0 , width: 49, height: 31))
        uiswitch.addTarget(self, action: #selector(changeSwitch), for: UIControl.Event.valueChanged)
        return uiswitch
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.modeColor
        
//        view.addSubview(letterSlider)
        view.addSubview(uiswitch)
    }
    
    override func viewDidLayoutSubviews() {
        
//        letterSlider.center = view.center
        
        uiswitchLayout()
    }
    
    private func uiswitchLayout() {
        
        uiswitch.center = view.center
        
        if appDelegate?.overrideUserInterfaceStyle == .dark {
            uiswitch.isOn = true
        } else {
            uiswitch.isOn = false
        }
    }
    
    @objc func changeSwitch(sender: UISwitch) {
        
        if #available(iOS 13.0, *) {
            
            let onCheck: Bool = sender.isOn
            
            if onCheck {
                appDelegate?.overrideUserInterfaceStyle = .dark
            } else {
                appDelegate?.overrideUserInterfaceStyle = .light
            }
        }
    }
    
    @objc func onStartPointlabel(_ sender:UISlider!) {
        
        print(sender.value)
    }
}


