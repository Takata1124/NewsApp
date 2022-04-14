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

    private var filterdFeedItems: [FeedItem] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }

    var articleUrl: String = ""
    var titleName: String = ""
    var buttonTitle: String = "New"
    
    var collectionModel: CollectionModel? {
        didSet {
            registerModel()
        }
    }
    
    private let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionModel = CollectionModel()
        
        if filterdFeedItems == [] {
            collectionModel?.getXMLData()
        }
        
        setupLayout()
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
        self.filterdFeedItems = model.filterFeedItems
        
        model.notificationCenter.addObserver(forName: .init(rawValue: CollectionModel.notificationName), object: nil, queue: nil) { [weak self] nortification in
            
            if let filterfeeditems = nortification.userInfo?["item"] as? [FeedItem] {
                
                self?.filterdFeedItems = filterfeeditems
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
        
        if filterdFeedItems == [] {
            collectionModel?.getXMLData()
        } else {
            collectionModel?.comparedFeedItem()
        }
        refreshControl.endRefreshing()
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
