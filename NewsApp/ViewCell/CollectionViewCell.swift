//
//  CollectionViewCell.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/07.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let identifier = "collectionViewCell"
    
    private var feedItem: FeedItem?
    
    let textLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.textLabel.font = UIFont.systemFont(ofSize: CGFloat(appDelegate.letterSize))
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
  
        self.addSubview(textLabel)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
        
    }
    
    func configureWithItem(item: FeedItem, cellType: CellType) {

        self.feedItem = item
        updateConstraintsWithCellType(cellType: cellType)
        
    }
    
    func updateConstraintsWithCellType(cellType: CellType) {
        
        if let item = self.feedItem {
            textLabel.text = item.title
            //                nameLabel?.text = item.name
        }
        
        switch cellType {
        case .List:
            textLabel.frame = CGRect(x: self.bounds.width / 2 - 150, y: self.bounds.height / 2 - 25, width: 300, height: 50)
            textLabel.textAlignment = .center
//            backgroundColor = UIColor.white
//            idLabel.textColor = UIColor.red
//            nameLabel.textColor = UIColor.black
//            nameLabelCenterXLayoutConstraint?.constant = -100
//            nameLabelCenterYLayoutConstraint?.constant = 0
//            bottomView.hidden = false
            
        case .Grid:
            textLabel.frame = CGRect(x: self.bounds.width / 2 - 75, y: self.bounds.height / 2 -  25, width: 150, height: 50)
            textLabel.textAlignment = .left
//            backgroundColor = UIColor.darkGray
//            idLabel.textColor = UIColor.blue
//            nameLabel.textColor = UIColor.brown
//            nameLabelCenterXLayoutConstraint?.constant = 0
//            nameLabelCenterYLayoutConstraint?.constant = 50
//            bottomView.hidden = true
        }
    }
}