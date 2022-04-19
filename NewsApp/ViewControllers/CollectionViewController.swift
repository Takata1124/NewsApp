//
//  CollectionViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/07.
//

import UIKit
import RealmSwift
import SwipeCellKit

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nortificationButton: UIBarButtonItem!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var starButton: UIButton!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var afterReadButton: UIButton!
 
    private let userDefaults = UserDefaults.standard
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private let refreshControl = UIRefreshControl()
    private let bounds = UIScreen.main.bounds
    private let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
    
    private var dataAlert: Bool = false {
        didSet {
            if dataAlert {
                nortificationButton.image = UIImage(systemName: "bell.fill")
            } else {
                nortificationButton.image = UIImage(systemName: "bell")
            }
        }
    }
    
    var filterFeedItems: [FeedItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var articleUrl: String = ""
    var titleName: String = ""
    var star: Bool = false
    var indexPathRow: Int = 0
    
    var buttonTitle: String = "Order" {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.orderButton.setTitle(self.buttonTitle, for: .normal)
            }
        }
    }
    
    var deleteAction: Bool = false {
        didSet {
            if deleteAction {
                self.filterFeedItems = []
                collectionModel?.deleteItems()
            }
        }
    }
    
    var collectionModel: CollectionModel? {
        didSet {
            registerModel()
        }
    }
    
    private var isReadFilter: Bool = false {
        didSet {
            readButton.tintColor = self.isReadFilter ? UIColor.red : UIColor.modeTextColor
        }
    }
    
    private var isStarFilter: Bool = false {
        didSet {
            starButton.tintColor = self.isStarFilter ? UIColor.red : UIColor.modeTextColor
        }
    }
    
    private var isAfterReadFilter: Bool = false {
        didSet {
            afterReadButton.tintColor = self.isAfterReadFilter ? UIColor.red : UIColor.modeTextColor
        }
    }
    
    var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionModel = CollectionModel()
        
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if filterFeedItems == [] {
            collectionModel?.getXMLData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.collectionView.reloadData()
        
        DispatchQueue.main.async {
            self.exchangeAnimation()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goArticle" {
            let articleView = segue.destination as! ArticleViewController
            articleView.articleUrl = self.articleUrl
            articleView.titleName = self.titleName
            articleView.indexPathRow = self.indexPathRow
        }
    }
    
    private func registerModel() {
        
        guard let model = collectionModel else { return }
        self.filterFeedItems = model.filterFeedItems
        
        model.notificationCenter.addObserver(forName: .init(rawValue: CollectionModel.notificationName), object: nil, queue: nil) { [weak self] nortification in
            
            if let filterfeeditems = nortification.userInfo?["item"] as? [FeedItem] {
                self?.filterFeedItems = filterfeeditems
                self?.collectionView.reloadData()
            }
        }
        
        model.notificationCenter.addObserver(forName: Notification.Name(CollectionModel.notificationAlertName), object: nil, queue: nil) { notification in
            if let alert = notification.userInfo?["alert"] as? Bool {
                self.dataAlert = alert
            }
        }
    }
    
    private func setupLayout() {
        
        let feed = collectionModel?.rssFeed()
        navigationItem.title = feed
        //戻るボタン非表示
        self.navigationItem.hidesBackButton = true
        
        orderButton.setTitle(buttonTitle, for: .normal)
        orderButton.tintColor = .modeTextColor
        starButton.tintColor = .modeTextColor
        readButton.tintColor = .modeTextColor
        afterReadButton.tintColor = .modeTextColor
        
        nortificationButton.image = UIImage(systemName: "bell")
        
        collectionView.collectionViewLayout = appDelegate.cellType.layoutFromSuperviewRect(rect: bounds)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView!.register(nib, forCellWithReuseIdentifier: "Cell")
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(CollectionViewController.refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        //
        if isReadFilter == true || isStarFilter == true || isAfterReadFilter == true {
            refreshControl.endRefreshing()
            return
        }
        
        if filterFeedItems == [] {
            collectionModel?.getXMLData()
        }
        
        if filterFeedItems != [] && appDelegate.storeFeedItems != [] {
            collectionModel?.comparedFeedItem(completion: {
                self.collectionModel?.deleteStoreFeedItems()
            })
        }
        
        if filterFeedItems != [] && appDelegate.storeFeedItems == [] {
            collectionModel?.getXMLData()
        }
        
        refreshControl.endRefreshing()
    }
    
    @IBAction func newOrder(_ sender: Any) {
        self.buttonTitle = collectionModel?.makingNewOrder(buttonTitle: self.buttonTitle) ?? ""
    }
    
    @IBAction func filterStar(_ sender: Any) {
        
        if isReadFilter == true || isAfterReadFilter == true { return }
   
        collectionModel?.filterStar(isReadFilter: isReadFilter, isStarFilter: isStarFilter, buttonTitle: buttonTitle)
        self.isStarFilter.toggle()
    }
    
    @IBAction func goSetting(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goSetting", sender: nil)
    }
    
    private func exchangeAnimation() {
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            
            guard let `self` = self else { return }
            
            self.collectionView?.collectionViewLayout = self.appDelegate.cellType.layoutFromSuperviewRect(rect: self.collectionView!.frame)
            self.collectionView?.visibleCells.forEach { cell in
                
                guard let _cell = cell as? CollectionViewCell else { return }
                _cell.updateConstraintsWithCellType(cellType: self.appDelegate.cellType)
            }
        })
    }
    
    @IBAction func filterRead(_ sender: Any) {
        
        if isStarFilter == true || isAfterReadFilter == true { return }
  
        collectionModel?.filterRead(isReadFilter: isReadFilter, isStarFilter: isStarFilter, buttonTitle: buttonTitle)
        self.isReadFilter.toggle()
    }
    
    @IBAction func filterAfterRead(_ sender: Any) {
        
        if isStarFilter == true || isReadFilter == true { return }
    
        collectionModel?.filterAfterReadAction(isAfterReadFilter: isAfterReadFilter, buttonTitle: buttonTitle)
        self.isAfterReadFilter.toggle()
    }
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, SwipeCollectionViewCellDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filterFeedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let feeditem = filterFeedItems[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.textLabel.font = UIFont.systemFont(ofSize: CGFloat(appDelegate.letterSize))
        cell.dateLabel.font = UIFont.systemFont(ofSize: CGFloat(10))
        cell.configureWithItem(item: feeditem, cellType: appDelegate.cellType)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.articleUrl = filterFeedItems[indexPath.row].url
        self.titleName = filterFeedItems[indexPath.row].title
        self.indexPathRow = indexPath.row
        
        self.collectionModel?.saveSelected(indexPath: indexPath)
        
        performSegue(withIdentifier: "goArticle", sender: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let starAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            
            self.filterFeedItems[indexPath.row].star.toggle()
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            guard let selectTitle = self.filterFeedItems[indexPath.row].title else { return }
            self.collectionModel?.saveStar(title: selectTitle)
        }
        
        starAction.image = UIImage(systemName: "star")
        starAction.backgroundColor = .systemOrange
        starAction.font = UIFont.systemFont(ofSize: CGFloat(10))
        starAction.textColor = .modeTextColor
        
        let readAction = SwipeAction(style: .destructive, title: "") { action, indexPath in
            
            self.filterFeedItems[indexPath.row].afterRead.toggle()
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
            guard let selectTitle = self.filterFeedItems[indexPath.row].title else { return }
            self.collectionModel?.saveAfterRead(title: selectTitle)
        }
        
        readAction.image = UIImage(systemName: "book")
        readAction.backgroundColor = .systemBlue
        readAction.font = UIFont.systemFont(ofSize: CGFloat(10))
        readAction.textColor = .modeTextColor
        
        let actionArray: [SwipeAction] = [starAction, readAction]
        
        return actionArray
    }
    
    func collectionView(_ collectionView: UICollectionView, editActionsOptionsForItemAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .drag
        return options
    }
}
