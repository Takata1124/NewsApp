//
//  BaseSwitch.swift
//  NewsApp
//
//  Created by t032fj on 2022/05/08.
//

import Foundation
import UIKit

class BaseSwitch: UISwitch {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2, width: 50, height: 31)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
