//
//  CollectionViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/07.
//

import UIKit

struct Item {
    
    let id: String
    let name: String
    let description: String
}

enum CellType {
    
    case List
    case Grid
    
    func layoutFromSuperviewRect(rect: CGRect) -> UICollectionViewFlowLayout {
        
        switch self {
            
        case .List:
            
            let layout = UICollectionViewFlowLayout()
            
            layout.itemSize = CGSize(width: rect.size.width, height: 60)
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

class CollectionViewController: UIViewController, UICollectionViewDelegate {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cellType: CellType = .List
    private var items: [Item] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        toggleButton.title = cellType.toggleButtonItemTitle
        
        let bounds = UIScreen.main.bounds
        
        collectionView.collectionViewLayout = cellType.layoutFromSuperviewRect(rect: bounds)
        
        for id in 0..<10 {
            let item = Item(id: "\(id)", name: "\(id)", description: "\(id)")
            items.append(item)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView!.register(nib, forCellWithReuseIdentifier: "Cell")
    }
    
    @IBAction func collectionChange(_ sender: Any) {
        
        switch cellType {
        case .List:
            cellType = .Grid
        case .Grid:
            cellType = .List
        }
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            
            guard let `self` = self else { return }
            
            self.collectionView?.collectionViewLayout = self.cellType.layoutFromSuperviewRect(rect: self.collectionView!.frame)
            
            self.collectionView?.visibleCells.forEach { cell in
                
                guard let _cell = cell as? CollectionViewCell else { return }
                
                _cell.updateConstraintsWithCellType(cellType: self.cellType)
            }
            
        }, completion: { [weak self] _ in
            guard let `self` = self else { return }
            
            self.toggleButton.title = self.cellType.toggleButtonItemTitle
        })
    }
    
    
    @IBAction func segmetnControl(_ sender: Any) {
        
        let selectedIndex = segment.selectedSegmentIndex
    }
}

extension CollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let item = items[indexPath.row]
        cell.configureWithItem(item: item, cellType: cellType)
        
        return cell
    }
}
