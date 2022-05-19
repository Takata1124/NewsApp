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
    
    var dataAlert: Bool = false {
        didSet {
            if NSClassFromString("XCTest") == nil {
                if self.dataAlert {
                    self.nortificationButton.image = UIImage(systemName: "bell.fill")
                } else {
                    self.nortificationButton.image = UIImage(systemName: "bell")
                }
            }
        }
    }
    
    var filterFeedItems: [FeedItem] = [] {
        didSet {
            if NSClassFromString("XCTest") == nil {
                DispatchQueue.main.async {
                    if let feed = self.collectionModel?.selectFeed {
                        self.navigationItem.title = "\(feed) (\(self.filterFeedItems.count))"
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
    
    var articleUrl: String = ""
    var titleName: String = ""
    var indexPathRow: Int = 0
    
    var buttonTitle: String = "Random" {
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
                collectionModel?.deleteTableItems()
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
    var realm: Realm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionModel = CollectionModel()
        
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //初回ログイン時のみ処理
        self.realm = appDelegate.realm
        let realmFeedItem = realm?.objects(RealmFeedItem.self)
        if realmFeedItem?.count == 0 {
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
        
        setupFilterFeedItemNotification(model: model)
        
        setupAlertNotification(model: model)
    }
    
    private func setupAlertNotification(model: CollectionModel) {
        
        self.filterFeedItems = model.filterFeedItems
        
        model.notificationCenter.addObserver(forName: Notification.Name(CollectionModel.notificationAlertName), object: nil, queue: nil) { notification in
            
            if let alert = notification.userInfo?["alert"] as? Bool {
                self.dataAlert = alert
            }
        }
    }
    
    private func setupFilterFeedItemNotification(model: CollectionModel) {
        
        model.notificationCenter.addObserver(forName: .init(rawValue: CollectionModel.notificationName), object: nil, queue: nil) { [weak self] nortification in
            
            if let filterfeeditems = nortification.userInfo?["item"] as? [FeedItem] {
                
                self?.filterFeedItems = []
                
                if self!.isStarFilter == true {
                    filterfeeditems.forEach { item in
                        if item.star == true {
                            self?.filterFeedItems.append(item)
                        }
                    }
                    return
                }
                
                if self!.isReadFilter == true {
                    filterfeeditems.forEach { item in
                        if item.read == true {
                            self?.filterFeedItems.append(item)
                        }
                    }
                    return
                }
                
                if self!.isAfterReadFilter == true {
                    filterfeeditems.forEach { item in
                        if item.afterRead == true {
                            self?.filterFeedItems.append(item)
                        }
                    }
                    return
                }
                
                self?.filterFeedItems = filterfeeditems
            }
        }
    }
    
    private func setupLayout() {
        
        self.navigationItem.hidesBackButton = true
        
        orderButton.setTitle(buttonTitle, for: .normal)
        orderButton.tintColor = .modeTextColor
        starButton.tintColor = .modeTextColor
        readButton.tintColor = .modeTextColor
        afterReadButton.tintColor = .modeTextColor
        
        if appDelegate.storedFeedItems != [] {
            nortificationButton.image = UIImage(systemName: "bell.fill")
        } else {
            nortificationButton.image = UIImage(systemName: "bell")
        }
        
        collectionView.collectionViewLayout = appDelegate.cellType.layoutFromSuperviewRect(rect: bounds)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView!.register(nib, forCellWithReuseIdentifier: "Cell")
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(CollectionViewController.refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        
        if isReadFilter == true || isStarFilter == true || isAfterReadFilter == true {
            refreshControl.endRefreshing()
            return
        }
        
        if filterFeedItems != [] && appDelegate.storedFeedItems != [] {
            
            collectionModel?.comparedFeedItem(feedItems: appDelegate.storedFeedItems, completion: { FeedItems in
                
                self.collectionModel?.saveFeedItems(feedItems: FeedItems)
                self.collectionModel?.nowfilterFeedItemOrder(buttonTitle: self.buttonTitle)
                self.collectionModel?.deleteStoredFeedItems()
                self.appDelegate.storedFeedItems = []
            })
            
        } else {
            
            collectionModel?.getXMLData()
        }
        //budge削除
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        refreshControl.endRefreshing()
    }
    
    @IBAction func newOrder(_ sender: Any) {
        self.buttonTitle = collectionModel?.makingNewOrder(buttonTitle: self.buttonTitle) ?? ""
    }
    
    @IBAction func filterStar(_ sender: Any) {
        
        if isReadFilter == true || isAfterReadFilter == true { return }
        
        self.isStarFilter.toggle()
        collectionModel?.filterStar(isStarFilter: isStarFilter, buttonTitle: buttonTitle)
        collectionModel?.nowfilterFeedItemOrder(buttonTitle: buttonTitle)
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
        
        self.isReadFilter.toggle()
        collectionModel?.filterRead(isReadFilter: isReadFilter, buttonTitle: buttonTitle)
        collectionModel?.nowfilterFeedItemOrder(buttonTitle: buttonTitle)
    }
    
    @IBAction func filterAfterRead(_ sender: Any) {
        
        if isStarFilter == true || isReadFilter == true { return }
        
        self.isAfterReadFilter.toggle()
        collectionModel?.filterAfterReadAction(isAfterReadFilter: isAfterReadFilter, buttonTitle: buttonTitle)
        collectionModel?.nowfilterFeedItemOrder(buttonTitle: buttonTitle)
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
        
        self.collectionModel?.saveSelected(index: indexPath.row)
        
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
