//
//  UILabel.swift
//  NewsApp
//
//  Created by t032fj on 2022/05/08.
//

import Foundation
import UIKit

class BaseLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tintColor = .modeTextColor
        self.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
