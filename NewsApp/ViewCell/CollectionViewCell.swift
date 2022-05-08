//
//  CollectionViewCell.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/07.
//

import UIKit
import SwipeCellKit

class CollectionViewCell: SwipeCollectionViewCell {

    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    static let identifier = "collectionViewCell"
    private var feedItem: FeedItem?
    
    private var read: Bool = false {
        didSet {
            if read {
                self.backgroundColor = .systemGray4
            } else {
                self.backgroundColor = .clear
            }
        }
    }
    
    private var star: Bool = false {
        didSet {
            if star {
                self.starImage.image = UIImage(systemName: "star.fill")
            } else {
                self.starImage.image = UIImage(systemName: "star")
            }
        }
    }
    
    let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let starImage: UIImageView = {
        let image = UIImageView()
        image.tintColor = .modeTextColor
        return image
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.modeTextColor.cgColor
        
        self.addSubview(textLabel)
        self.addSubview(dateLabel)
        self.addSubview(starImage)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        self.layer.borderColor = UIColor.modeTextColor.cgColor
    }
    
    func configureWithItem(item: FeedItem, cellType: CellType) {
        
        self.feedItem = item
        self.star = item.star
        self.read = item.read
        
        updateConstraintsWithCellType(cellType: cellType)
    }
    
    func updateConstraintsWithCellType(cellType: CellType) {
        
        if let item = self.feedItem {
            textLabel.text = item.title
            dateLabel.text = item.pubDate
        }
        
        switch cellType {
            
        case .List:
            textLabel.frame = CGRect(x: self.bounds.width / 2 - 150, y: self.bounds.height / 2 - 25, width: 300, height: 50)
            textLabel.textAlignment = .left
            dateLabel.frame = CGRect(x: self.bounds.width / 2 - 150, y: self.bounds.height / 2, width: 300, height: 50)
            dateLabel.textAlignment = .right
            starImage.frame = CGRect(x: 10, y: self.bounds.height / 2 - 10, width: 20, height: 20)
            
        case .Grid:
            textLabel.frame = CGRect(x: self.bounds.width / 2 - 75, y: self.bounds.height / 2 -  25, width: 150, height: 50)
            textLabel.textAlignment = .left
            dateLabel.frame = CGRect(x: self.bounds.width / 2 - 75, y: self.bounds.height * 1.5 / 2, width: 150, height: 50)
            dateLabel.textAlignment = .right
            starImage.frame = CGRect(x: 10, y: 20, width: 20, height: 20)
        }
    }
}
