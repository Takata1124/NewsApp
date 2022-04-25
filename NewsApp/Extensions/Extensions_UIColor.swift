//
//  Extensions_UIColor.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/06.
//

import Foundation
import UIKit

extension UIColor {
    
    class var modeColor: UIColor {
        return UIColor(named: "modeColor")!
    }
    
    class var modeTextColor: UIColor {
        return UIColor(named: "modeTextColor")!
    }
    
//    public class func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
//
//        if #available(iOS 13, *) {
//            return UIColor { (traitCollection) -> UIColor in
//                if traitCollection.userInterfaceStyle == .dark {
//                    return dark
//                } else {
//                    return light
//                }
//            }
//        }
//        return light
//    }
}
