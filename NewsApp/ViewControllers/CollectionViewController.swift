//
//  CollectionViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/07.
//

import UIKit
import RealmSwift

class CollectionViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nortificationButton: UIBarButtonItem!
    @IBOutlet weak var orderButton: UIButton!
    
    private let userDefaults = UserDefaults.standard
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private let refreshControl = UIRefreshControl()
    
    let bounds = UIScreen.main.bounds
    let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
    
    private var filterFeedItems: [FeedItem] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var articleUrl: String = ""
    var titleName: String = ""
    var buttonTitle: String = "New"
    
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
    
    private let realm = try! Realm()
    
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
    }
    
    private func setupLayout() {
        
        let feed = collectionModel?.rssFeed()
        navigationItem.title = feed
        
        orderButton.setTitle(buttonTitle, for: .normal)
        orderButton.tintColor = .modeTextColor
        
        if appDelegate.newDataAlert {
            nortificationButton.image = UIImage(systemName: "bell.fill")
        } else {
            nortificationButton.image = UIImage(systemName: "bell")
        }
        nortificationButton.image = UIImage(systemName: "bell")
        
        collectionView.collectionViewLayout = appDelegate.cellType.layoutFromSuperviewRect(rect: bounds)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView!.register(nib, forCellWithReuseIdentifier: "Cell")
        collectionView.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(CollectionViewController.refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        
        if filterFeedItems == [] {
            collectionModel?.getXMLData()
        } else {
            collectionModel?.comparedFeedItem()
        }
        
        refreshControl.endRefreshing()
    }
    
    @IBAction func newOrder(_ sender: Any) {
        
        if buttonTitle == "New" {
            filterFeedItems.sort { item_1, item_2 in
                item_1.pubDate < item_2.pubDate
            }
            DispatchQueue.main.async {
                self.buttonTitle = "Old"
                self.collectionView.reloadData()
                self.orderButton.setTitle(self.buttonTitle, for: .normal)
            }
            
        } else {
            filterFeedItems.sort { item_1, item_2 in
                item_1.pubDate > item_2.pubDate
            }
            DispatchQueue.main.async {
                self.buttonTitle = "New"
                self.collectionView.reloadData()
                self.orderButton.setTitle(self.buttonTitle, for: .normal)
            }
        }
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
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filterFeedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        let feeditem = filterFeedItems[indexPath.row]
        
        cell.textLabel.font = UIFont.systemFont(ofSize: CGFloat(appDelegate.letterSize))
        cell.dateLabel.font = UIFont.systemFont(ofSize: CGFloat(10))
        cell.configureWithItem(item: feeditem, cellType: appDelegate.cellType)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.articleUrl = filterFeedItems[indexPath.row].url
        self.titleName = filterFeedItems[indexPath.row].title

        saveSelected(indexPath: indexPath)
        
        performSegue(withIdentifier: "goArticle", sender: nil)
    }
    
    private func saveSelected(indexPath: IndexPath) {
        
        let selectItem = filterFeedItems[indexPath.row]
        let newFeedItem = FeedItem(title: selectItem.title, url: selectItem.url, pubDate: selectItem.pubDate, star: selectItem.star, read: true)
        self.filterFeedItems[indexPath.row] = newFeedItem
        let selectedTitle: String = self.filterFeedItems[indexPath.row].title
        self.collectionModel?.saveSelected(title: selectedTitle)
    }
}
