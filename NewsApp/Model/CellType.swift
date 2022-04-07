//
//  CellType.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/07.
//

import Foundation
import UIKit

enum CellType {
    
    case List
    case Grid
    
    func layoutFromSuperviewRect(rect: CGRect) -> UICollectionViewFlowLayout {
        
        switch self {
            
        case .List:
            
            let layout = UICollectionViewFlowLayout()
            
            layout.itemSize = CGSize(width: rect.size.width, height: 75)
            layout.minimumLineSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            
            return layout
        case .Grid:
            
            let layout = UICollectionViewFlowLayout()
            
            layout.itemSize = CGSize(width: (rect.size.width - 30) / 2, height: (rect.size.width - 30) / 2)
            layout.minimumLineSpacing = 15
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            
            return layout
        }
    }
    
    var toggleButtonItemTitle: String {
        
        switch self {
        case .List:
            return "LIST"
        case .Grid:
            return "GRID"
        }
    }
}
