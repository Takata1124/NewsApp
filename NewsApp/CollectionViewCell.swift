//
//  CollectionViewCell.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/07.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    static let identifier = "collectionViewCell"
    
    private var item: Item?
    
    @IBOutlet weak var textLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
    }
    
    func configureWithItem(item: Item, cellType: CellType) {

        self.item = item
        updateConstraintsWithCellType(cellType: cellType)
    }
    
    func updateConstraintsWithCellType(cellType: CellType) {
        
        if let item = self.item {
            textLabel?.text = item.id
            //                nameLabel?.text = item.name
        }
        
        switch cellType {
        case .List:
            print("good")
//            backgroundColor = UIColor.white
//            idLabel.textColor = UIColor.red
//            nameLabel.textColor = UIColor.black
//            nameLabelCenterXLayoutConstraint?.constant = -100
//            nameLabelCenterYLayoutConstraint?.constant = 0
//            bottomView.hidden = false
        case .Grid:
            print("great")
//            backgroundColor = UIColor.darkGray
//            idLabel.textColor = UIColor.blue
//            nameLabel.textColor = UIColor.brown
//            nameLabelCenterXLayoutConstraint?.constant = 0
//            nameLabelCenterYLayoutConstraint?.constant = 50
//            bottomView.hidden = true
        }
    }
}
