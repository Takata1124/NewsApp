//
//  CollectionModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/13.
//

import Foundation
import RealmSwift

class CollectionModel: NSObject {
    
//    static let shared = CollectionModel()
    let notificationCenter = NotificationCenter()
    static let notificationName = "CollectionData"
    static let notificationAlertName = "AlertStoreData"
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var selectFeed: String = ""
    private var feedUrl: String = ""
    
    private(set) var feedItems: [FeedItem] = [] {
        didSet {
            filterFunc(feedItems: feedItems) {
                self.saveFeedData(feedItems: self.feedItems)
            }
        }
    }
    
    private(set) var filterFeedItems: [FeedItem] = [] {
        didSet {
            notificationCenter.post(name: .init(rawValue: CollectionModel.notificationName), object: nil, userInfo: ["item" : filterFeedItems])
        }
    }
    
    func deleteItems() {
        self.feedItems = []
        self.filterFeedItems = []
    }
    
    let userDefaults = UserDefaults.standard
    
    private let realm = try! Realm()
    
    private let item_name = "item"
    private let title_name = "title"
    private let link_name  = "link"
    private let pubDate_name = "pubDate"
    
    private var parser: XMLParser?
    private var currrentElementName: String?
    
    override init() {
        super.init()
        
        fetchUserFeed()
        getFeedUrl(self.selectFeed)
        fetchFeedDate()
        
        notificationAlert()
    }
    
    private func fetchUserFeed() {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return }
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        self.selectFeed = user.feed
    }
    
    private func filterFunc(feedItems: [FeedItem], completion: @escaping() -> Void) {
        
        var i = 0
        feedItems.forEach { feed in
            if feed.url != "" && !feed.title.contains("Yahoo!ニュース・トピックス") {
                
                if !filterFeedItems.contains(where: { feeditem in
                    feeditem.title == feed.title
                }) {
                    filterFeedItems.append(feed)
                }
            }
            i += 1
            
            if i == feedItems.count {
                completion()
            }
        }
    }
    
    func rssFeed() -> String {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return "一覧" }
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        let feed = user.feed
        return feed
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
    //保存データの設置
    func fetchFeedDate() {
        
        let result = realm.objects(RealmFeedItem.self)
        
        result.forEach { item in
            if !item.title.contains("Yahoo!ニュース・トピックス") {
                let feeditem = FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead)
                guard let title = feeditem.title else { return }
                if title != "" {
                    filterFeedItems.append(feeditem)
                }
            }
        }
    }
    //更新データの有無を通知
    func notificationAlert() {
        
        if appDelegate.storeFeedItems != [] {
            DispatchQueue.main.async {
                self.notificationCenter.post(name: Notification.Name(CollectionModel.notificationAlertName), object: nil, userInfo: ["alert": true])
            }
        }
    }
    
    private func saveFeedData(feedItems: [FeedItem]) {
        
        let selectRealmItem = realm.objects(RealmFeedItem.self)
        
        feedItems.forEach { item in
            
            if !selectRealmItem.contains(where: { realmitem in
                realmitem.title == item.title
            }) {
                let realmFeedItem = RealmFeedItem()
                realmFeedItem.title = item.title
                realmFeedItem.url = item.url
                realmFeedItem.pubDate = item.pubDate
                
                try! realm.write({
                    realm.add(realmFeedItem)
                })
            }
        }
    }
    
    func comparedFeedItem() {
        
        let storeFeedItem = realm.objects(StoreFeedItem.self)
        var tempFeedItems: [FeedItem] = []
        var i = 0
        
        storeFeedItem.forEach { storeItem in
            
            i += 1
            if !filterFeedItems.contains(where: { item in
                item.title == storeItem.title
            }) && !storeItem.title.contains("Yahoo!ニュース・トピックス") {
                let tempItem = FeedItem(title: storeItem.title, url: storeItem.url, pubDate: storeItem.pubDate, star: false, read: false, afterRead: false)
                tempFeedItems.append(tempItem)
            }
            
            if i == storeFeedItem.count {
                feedItems += tempFeedItems
                
                let results = realm.objects(StoreFeedItem.self)
                try! realm.write {
                    realm.delete(results)
                }
            }
        }
    }
    
    func saveSelected(indexPath: IndexPath) {
        
        let selectItem = filterFeedItems[indexPath.row]
        let newFeedItem = FeedItem(title: selectItem.title, url: selectItem.url, pubDate: selectItem.pubDate, star: selectItem.star, read: true, afterRead: selectItem.afterRead)
        self.filterFeedItems[indexPath.row] = newFeedItem
        let selectedTitle: String = self.filterFeedItems[indexPath.row].title
        
        let predicate = NSPredicate(format: "title == %@", "\(selectedTitle)")
        let result = realm.objects(RealmFeedItem.self).filter(predicate)
        
        do{
            try realm.write{
                result[0].read = true
            }
        }catch {
            print("Error \(error)")
        }
    }
    
    func saveStar(title: String) {
        
        let predicate = NSPredicate(format: "title == %@", "\(title)")
        let result = realm.objects(RealmFeedItem.self).filter(predicate)
        
        if result[0].star == false {
            do{
                try realm.write{
                    result[0].star = true
                }
            }catch {
                print("Error \(error)")
            }
        } else {
            do{
                try realm.write{
                    result[0].star = false
                }
            }catch {
                print("Error \(error)")
            }
        }
    }
    
    func saveAfterRead(title: String) {
        
        let predicate = NSPredicate(format: "title == %@", "\(title)")
        let result = realm.objects(RealmFeedItem.self).filter(predicate)
        
        if result[0].afterRead == false {
            do{
                try realm.write{
                    result[0].afterRead = true
                }
            }catch {
                print("Error \(error)")
            }
        } else {
            do{
                try realm.write{
                    result[0].afterRead = false
                }
            }catch {
                print("Error \(error)")
            }
        }
    }
    
    func makingNewOrder(buttonTitle: String) -> String {
        
        if buttonTitle == "New" {
            filterFeedItems.sort { item_1, item_2 in
                item_1.pubDate < item_2.pubDate
            }
            return "Old"
        }
        
        filterFeedItems.sort { item_1, item_2 in
            item_1.pubDate > item_2.pubDate
        }
        return "New"
    }
    
    func filterStar(isReadFilter: Bool, isStarFilter: Bool, buttonTitle: String) {
        
        if isReadFilter { return }
        
        if isStarFilter {
            self.deleteItems()
            self.fetchFeedDate()
        } else {
            let filterArray = self.filterFeedItems.filter { item in
                item.star == true
            }
            self.filterFeedItems = filterArray
        }

        if buttonTitle == "New" {
            filterFeedItems.sort { item_1, item_2 in
                item_1.pubDate > item_2.pubDate
            }
            return
        }
        if buttonTitle == "Old" {
            filterFeedItems.sort { item_1, item_2 in
                item_1.pubDate < item_2.pubDate
            }
            return
        }
    }
    
    func filterRead(isReadFilter: Bool, isStarFilter: Bool, buttonTitle: String) {
        
        if isStarFilter { return }
        
        if isReadFilter {
            self.deleteItems()
            self.fetchFeedDate()
        } else {
            let filterArray = self.filterFeedItems.filter { item in
                item.read == false
            }
            self.filterFeedItems = filterArray
        }
        
        if buttonTitle == "New" {
            filterFeedItems.sort { item_1, item_2 in
                item_1.pubDate > item_2.pubDate
            }
            return
        }
        
        if buttonTitle == "Old" {
            filterFeedItems.sort { item_1, item_2 in
                item_1.pubDate < item_2.pubDate
            }
            return
        }
    }
    
    func filterAfterReadAction(isAfterReadFilter: Bool) {
        
        if isAfterReadFilter {
            self.deleteItems()
            self.fetchFeedDate()
        } else {
            let filterArray = self.filterFeedItems.filter { item in
                item.afterRead == true
            }
            self.filterFeedItems = filterArray
        }
    }
}

extension CollectionModel: XMLParserDelegate {
    
    func getXMLData() {
        
        let uslString: String = self.feedUrl
        
        guard let url = URL(string: uslString) else {
            return
        }
        
        let parser = XMLParser(contentsOf: url)
        
        if parser != nil {
            self.parser = parser
            self.parser?.delegate = self
            self.parser?.parse()
        } else {
            print("failed to parse XML")
        }
    }
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("XML解析開始しました")
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        self.currrentElementName = nil
        
        if elementName == item_name {
            self.feedItems.append(FeedItem(title: "", url: "", pubDate: "", star: false, read: false, afterRead: false))
        } else {
            currrentElementName = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if self.feedItems.count > 0 {
            
            let lastItem = self.feedItems[self.feedItems.count - 1]
            
            switch self.currrentElementName {
                
            case title_name:
                let tempString = lastItem.title
                lastItem.title = (tempString != nil) ? tempString! + string: string
                
            case link_name:
                lastItem.url = string
                
            case pubDate_name:
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "EEE, dd MMM yyyy hh:mm:ss Z"
                let date = dateFormatter.date(from: string) ?? Date()
                dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm Z"
                let dateString = dateFormatter.string(from: date)
                lastItem.pubDate = String(dateString.prefix(16))
                
            default:
                break
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        self.currrentElementName = nil
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("エラー:" + parseError.localizedDescription)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        
    }
}
