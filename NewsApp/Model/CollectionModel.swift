//
//  CollectionModel.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/13.
//

import Foundation
import RealmSwift

class CollectionModel: NSObject {
    
    static let shared = CollectionModel()
    let notificationCenter = NotificationCenter()
    static let notificationName = "CollectionData"
    static let notificationAlertName = "AlertStoreData"
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectFeed: String = ""
    var feedUrl: String = ""
    
    var feedItems: [FeedItem] = []
    
    var filterFeedItems: [FeedItem] = [] {
        didSet {
            notificationCenter.post(name: .init(rawValue: CollectionModel.notificationName), object: nil, userInfo: ["item" : filterFeedItems])
        }
    }
    
    var userDefaults: UserDefaults?
    var realm: Realm?
    
    private let item_name = "item"
    private let title_name = "title"
    private let link_name  = "link"
    private let pubDate_name = "pubDate"
    
    private var parser: XMLParser?
    private var currrentElementName: String?
    
    var realmFeedItem: Results<RealmFeedItem>?
    private var notificationToken: NotificationToken?
    
    var updateData: Bool = false
    
    init(userDefaults: UserDefaults = UserDefaults.standard, realm: Realm = try! Realm()) {
        super.init()
        
        self.userDefaults = userDefaults
        self.realm = realm
        
        fetchUserFeed()
        getFeedUrl(self.selectFeed)
        notificationAlert()
        setupRealmFeedItems()
    }
    
    func deleteTableItems() {
        
        self.filterFeedItems = []
    }
    
    func setupRealmFeedItems() {
        
        realmFeedItem = realm?.objects(RealmFeedItem.self)
        
        notificationToken = realmFeedItem?.observe{ [unowned self] changes in
            
            switch changes {
                
            case .initial(let items):
                
                if items.count > 0 {
                    
                    items.forEach { item in
                        
                        if queryConfirmAlreadyItem(item: item) {
                            
                            let newFeedItem = FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead)
                            self.filterFeedItems.append(newFeedItem)
                        }
                    }
                }
                
            case .update(let items, _, _, let modifications):
                
                if modifications == [] && items.count > 0 {
                    
                    items.forEach { item in
                        
                        if queryConfirmAlreadyItem(item: item) {
                            
                            let newFeedItem = FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead)
                            self.filterFeedItems.append(newFeedItem)
                        }
                    }
                }
                
                if modifications != [] {
                    
                    let index = filterFeedItems.firstIndex { item in
                        item.title == realmFeedItem?[modifications[0]].title
                    }
                    
                    if let index = index {
                        
                        let newFeedItem = FeedItem(
                            title: realmFeedItem?[modifications[0]].title ?? "",
                            url: realmFeedItem?[modifications[0]].url ?? "",
                            pubDate: realmFeedItem?[modifications[0]].pubDate ?? "",
                            star: realmFeedItem?[modifications[0]].star ?? false,
                            read: realmFeedItem?[modifications[0]].read ?? false,
                            afterRead: realmFeedItem?[modifications[0]].afterRead ?? false)
                        
                        self.filterFeedItems[index] = newFeedItem
                    }
                }
                
            case .error(let error):
                
                fatalError("\(error)")
            }
        }
    }
    
    func fetchUserFeed() {
        
        if let data: Data = userDefaults?.value(forKey: "User") as? Data {
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            self.selectFeed = user.feed
        }
    }
    
    func saveFeedItems(feedItems: [FeedItem]) {
        
        feedItems.forEach { feed in
            
            if queryFilterSaveData(title: feed.title, url: feed.url, pubDate: feed.pubDate) {
                
                let realmFeedItem = RealmFeedItem()
                realmFeedItem.title = feed.title
                realmFeedItem.url = feed.url
                realmFeedItem.pubDate = feed.pubDate
                
                try! realm?.write({
                    realm?.add(realmFeedItem)
                })
            }
        }
    }
    
    func queryFilterSaveData(title: String, url: String, pubDate: String)  -> Bool {
        
        return title != "" && url != "" && pubDate != "" && !title.contains("Yahoo!ニュース・トピックス") && !(realmFeedItem?.contains(where: { feeditem in
            feeditem.title == title
        }) ?? false)
    }
    
    func getFeedUrl(_ selectFeed: String) {
        
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
        
        let result = realm?.objects(RealmFeedItem.self)
        if result?.count == 0 { return }
        
        result?.forEach { item in
            
            if queryConfirmAlreadyItem(item: item) {
                
                let feeditem = FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead)
                
                filterFeedItems.append(feeditem)
            }
        }
    }
    
    func queryConfirmAlreadyItem(item: RealmFeedItem)  -> Bool {
        
        if self.filterFeedItems.contains(where: { filteritem in
            filteritem.title == item.title
        }) || item.title == "Yahoo!ニュース・トピックス" || item.title == "" {
            return false
        }
        
        return true
    }
    
    //更新データの有無を通知
    func notificationAlert() {
        
        if appDelegate.storedFeedItems != [] {
            
            self.notificationCenter.post(name: Notification.Name(CollectionModel.notificationAlertName), object: nil, userInfo: ["alert": true])
        } else {
            
            self.notificationCenter.post(name: Notification.Name(CollectionModel.notificationAlertName), object: nil, userInfo: ["alert": false])
        }
    }
    
    func comparedFeedItem(feedItems: [FeedItem], completion: @escaping([FeedItem]) -> Void) {
        
        var tempFeedItems: [FeedItem] = []
        let tempStoreFeedItems: [FeedItem] = feedItems
        
        for (index, storeItem) in tempStoreFeedItems.enumerated() {
            
            if queryCompareFeedItemsForSave(item: storeItem) {
                
                let tempItem = FeedItem(title: storeItem.title, url: storeItem.url, pubDate: storeItem.pubDate, star: false, read: false, afterRead: false)
                tempFeedItems.append(tempItem)
            }
            
            if index == tempStoreFeedItems.count - 1 {
                completion(tempFeedItems)
            }
        }
    }
    
    func queryCompareFeedItemsForSave(item: FeedItem)  -> Bool {
        
        if self.filterFeedItems.contains(where: { filteritem in
            filteritem.title == item.title
        }) || item.title == "Yahoo!ニュース・トピックス" || item.title == "" {
            return false
        }
        
        return true
    }
    
    func deleteStoredFeedItems() {
        
        userDefaults?.removeObject(forKey: "StoreFeedItems")
        self.notificationAlert()
    }
    
    func saveSelected(index: Int) {
        
        let selectedTitle: String = self.filterFeedItems[index].title
        let predicate = NSPredicate(format: "title == %@", "\(selectedTitle)")
        let result = realm?.objects(RealmFeedItem.self).filter(predicate)
        
        do {
            try realm?.write{
                result?[0].read = true
            }
        } catch {
            print("Error \(error)")
        }
    }
    
    func saveStar(title: String) {
        
        let predicate = NSPredicate(format: "title == %@", "\(title)")
        let result = realm?.objects(RealmFeedItem.self).filter(predicate)
        
        if result?[0].star == false {
            try! realm?.write {
                result?[0].star = true
            }
        } else {
            try! realm?.write {
                result?[0].star = false
            }
        }
    }
    
    func saveAfterRead(title: String) {
        
        let predicate = NSPredicate(format: "title == %@", "\(title)")
        let result = realm?.objects(RealmFeedItem.self).filter(predicate)
        
        if result?[0].afterRead == false {
            try! realm?.write {
                result?[0].afterRead = true
            }
        } else {
            try! realm?.write {
                result?[0].afterRead = false
            }
        }
    }
    
    func filterStar(isStarFilter: Bool, buttonTitle: String)  {

        if isStarFilter {

            let result = realm?.objects(RealmFeedItem.self).filter("star = true")
            var temporaryArray: [FeedItem] = []

            result?.forEach { item in
                temporaryArray.append(FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead))
                self.filterFeedItems = temporaryArray
            }
        } else {

            self.deleteTableItems()
            self.fetchFeedDate()
        }
    }
    
    func filterRead(isReadFilter: Bool, buttonTitle: String) {

        if isReadFilter {

            let result = realm?.objects(RealmFeedItem.self).filter("read = true")
            var temporaryArray: [FeedItem] = []

            result?.forEach { item in
                temporaryArray.append(FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead))
                self.filterFeedItems = temporaryArray
            }
        } else {

            self.deleteTableItems()
            self.fetchFeedDate()
        }
    }
    
    func filterAfterReadAction(isAfterReadFilter: Bool, buttonTitle: String) {

        if isAfterReadFilter {
            
            let result = realm?.objects(RealmFeedItem.self).filter("afterRead = true")
            var temporaryArray: [FeedItem] = []

            result?.forEach { item in
                temporaryArray.append(FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read, afterRead: item.afterRead))
                self.filterFeedItems = temporaryArray
            }

        } else {

            self.deleteTableItems()
            self.fetchFeedDate()
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
    
    func nowfilterFeedItemOrder(buttonTitle: String) {
        
        if buttonTitle == "New" {
            
            filterFeedItems.sort { item_1, item_2 in
                item_1.pubDate > item_2.pubDate
            }
            
            return
        }
        
        filterFeedItems.sort { item_1, item_2 in
            item_1.pubDate < item_2.pubDate
        }
        
        return
    }
}

extension CollectionModel: XMLParserDelegate {
    
    func getXMLData() {
        
        let uslString: String = self.feedUrl
        self.feedItems = []
        
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
        print("end")
        
        saveFeedItems(feedItems: self.feedItems)
    }
}
