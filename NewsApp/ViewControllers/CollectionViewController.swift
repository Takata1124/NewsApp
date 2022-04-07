//
//  CollectionViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/07.
//

import UIKit



class CollectionViewController: UIViewController {
    
    @IBOutlet weak var toggleButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var cellType: CellType = .List
    
    private let userDefaults = UserDefaults.standard
    
    let bounds = UIScreen.main.bounds
    let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
    
    var parser: XMLParser?
    
    var selectFeed: String = ""
    var feedUrl: String = ""
    var feedItems = [FeedItem]()
    var currrentElementName: String?
    
    let item_name = "item"
    let title_name = "title"
    let link_name  = "link"
    let pubDate_name = "pubDate"
    
    var articleUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        usergetFeed()
        getFeedUrl(self.selectFeed)
        getXMLData(urlString: feedUrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goArticle" {
            let articleView = segue.destination as! ArticleViewController
            articleView.articleUrl = self.articleUrl
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
        
        toggleButton.title = cellType.toggleButtonItemTitle
 
        collectionView.collectionViewLayout = cellType.layoutFromSuperviewRect(rect: bounds)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView!.register(nib, forCellWithReuseIdentifier: "Cell")
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
}

extension CollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        let feeditem = feedItems[indexPath.row]
        cell.configureWithItem(item: feeditem, cellType: cellType)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.articleUrl = feedItems[indexPath.row].url
        
        performSegue(withIdentifier: "goArticle", sender: nil)
    }
}

