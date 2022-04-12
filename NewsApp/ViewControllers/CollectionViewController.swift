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
    
    var parser: XMLParser?
    
    var selectFeed: String = ""
    var feedUrl: String = ""
    
    var feedTitles: [String] = []
    var feedItems = [FeedItem]() {
        didSet {
            filterFunc(feedItems: feedItems)
        }
    }
    
    var filterdFeedItems: [FeedItem] = []
    var storeFeedItem: [FeedItem] = []
    var currrentElementName: String?
    
    let item_name = "item"
    let title_name = "title"
    let link_name  = "link"
    let pubDate_name = "pubDate"
    
    var articleUrl: String = ""
    var titleName: String = ""
    var buttonTitle: String = "New"
    
    private let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        usergetFeed()
        fetchFeedDate()
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
    
    private func usergetFeed() {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return }
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        self.selectFeed = user.feed
    }
    
    private func setupLayout() {
        
        let feed = rssFeed()
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
    
    private func filterFunc(feedItems: [FeedItem]) {

        feedItems.forEach { feed in

            if feed.title != "" && !feed.title.contains("Yahoo!ニュース・トピックス") {
                if !feedTitles.contains(feed.title) {
                    filterdFeedItems.append(feed)

                    saveFeedData(feedItems: filterdFeedItems)

                    feedTitles.append(feed.title)
                    let tempArry = Array(Set(feedTitles))
                    feedTitles = tempArry
                }
            }
        }
    }

    @objc func refresh(sender: UIRefreshControl) {
        
        if filterdFeedItems == [] {
            
            getFeedUrl(self.selectFeed)
            getXMLData(urlString: feedUrl)
        } else {
            
            comparedFeedItem()
        }
  
        refreshControl.endRefreshing()
    }
    
    private func comparedFeedItem() {
        
        let tempFeedItem = realm.objects(StoreFeedItem.self)
        print(tempFeedItem)
        tempFeedItem.forEach { storeItem in
            if !feedTitles.contains(storeItem.title) && !storeItem.title.contains("Yahoo!ニュース・トピックス") {
                let tempItem = FeedItem(title: storeItem.title, url: storeItem.url, pubDate: storeItem.pubDate)
                filterdFeedItems.append(tempItem)
            }
        }
    }

    @IBAction func newOrder(_ sender: Any) {
        
        if buttonTitle == "New" {
            filterdFeedItems.sort { item_1, item_2 in
                item_1.pubDate > item_2.pubDate
            }
            DispatchQueue.main.async {
                self.buttonTitle = "Old"
                self.collectionView.reloadData()
                self.orderButton.setTitle(self.buttonTitle, for: .normal)
            }
            
        } else {
            
            filterdFeedItems.sort { item_1, item_2 in
                item_1.pubDate < item_2.pubDate
            }
            DispatchQueue.main.async {
                self.buttonTitle = "New"
                self.collectionView.reloadData()
                self.orderButton.setTitle(self.buttonTitle, for: .normal)
            }
        }
    }

    private func getFeedUrl(_ selectFeed: String) {
        
        switch selectFeed {
            
        case "主要":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/top-picks.xml"
        case "国内":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/domestic.xml"
        case "国際":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/world.xml"
        case "経済":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/business.xml"
        case "エンタメ":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/entertainment.xml"
        case "スポーツ":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/sports.xml"
        case "IT":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/it.xml"
        case "科学":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/science.xml"
        case "地域":
            self.feedUrl = "https://news.yahoo.co.jp/rss/topics/local.xml"
            
        default:
            print("urlを取得できませんでした")
        }
    }
    
    private func rssFeed() -> String {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return "一覧" }
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        let feed = user.feed
        return feed
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
            
        }, completion: { [weak self] _ in
            
            guard let `self` = self else { return }
        })
    }
    
    private func saveFeedData(feedItems: [FeedItem]) {

        let selectRealmItem = realm.objects(RealmFeedItem.self)
        
        try! realm.write {
            realm.delete(selectRealmItem)
        }
        
        feedItems.forEach { item in
            
            let realmFeedItem = RealmFeedItem()
            realmFeedItem.title = item.title
            realmFeedItem.url = item.url
            realmFeedItem.pubDate = item.pubDate
            
            try! realm.write({
                realm.add(realmFeedItem)
            })
        }
    }
    
    private func fetchFeedDate() {
        
        let result = realm.objects(RealmFeedItem.self)
        
        result.forEach { item in
            feedTitles.append(item.title)
           
            if !item.title.contains("Yahoo!ニュース・トピックス") {
                let feeditem = FeedItem(title: item.title, url: item.url, pubDate: item.pubDate)
                filterdFeedItems.append(feeditem)
            }
        }
    }
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filterdFeedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let feeditem = filterdFeedItems[indexPath.row]
        
        cell.textLabel.font = UIFont.systemFont(ofSize: CGFloat(appDelegate.letterSize))
        cell.dateLabel.font = UIFont.systemFont(ofSize: CGFloat(10))
        cell.configureWithItem(item: feeditem, cellType: appDelegate.cellType)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.articleUrl = filterdFeedItems[indexPath.row].url
        self.titleName = filterdFeedItems[indexPath.row].title
        
        performSegue(withIdentifier: "goArticle", sender: nil)
    }
}
