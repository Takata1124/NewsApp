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
    static let notificationName = "CollectionData"
    let notificationCenter = NotificationCenter()
    
    private var selectFeed: String = ""
    private var feedUrl: String = ""
    
    var feedTitles: [String] = []
    
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
        self.feedTitles = []
        self.feedItems = []
        self.filterFeedItems = []
    }
    
    let userDefaults = UserDefaults.standard
    
    private let realm = try! Realm()
    
    private let item_name = "item"
    private let title_name = "title"
    private let link_name  = "link"
    private let pubDate_name = "pubDate"
    
    var parser: XMLParser?
    
    var currrentElementName: String?
    
    override init() {
        super.init()
        
        fetchUserFeed()
        getFeedUrl(self.selectFeed)
        fetchFeedDate()
    }

    private func fetchUserFeed() {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return }
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        self.selectFeed = user.feed
    }
    
    private func filterFunc(feedItems: [FeedItem], completion: @escaping() -> Void) {
        
        var i = 0

        feedItems.forEach { feed in
            i += 1

            if feed.url != "" && !feed.title.contains("Yahoo!ニュース・トピックス") {
                
                if !feedTitles.contains(feed.title) {
                    filterFeedItems.append(feed)
                    feedTitles.append(feed.title)
                    
                    let tempArry = Array(Set(feedTitles))
                    feedTitles = tempArry
                }
            }
            
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
    
    private func fetchFeedDate() {

        let result = realm.objects(RealmFeedItem.self)

        result.forEach { item in
            feedTitles.append(item.title)
            if !item.title.contains("Yahoo!ニュース・トピックス") {
                let feeditem = FeedItem(title: item.title, url: item.url, pubDate: item.pubDate, star: item.star, read: item.read)
                guard let title = feeditem.title else { return }
                if title != "" {
                    filterFeedItems.append(feeditem)
                }
            }
        }
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
    
    func comparedFeedItem() {
        
        let storeFeedItem = realm.objects(StoreFeedItem.self)
        var tempFeedItems: [FeedItem] = []
        var i = 0
        
        storeFeedItem.forEach { storeItem in
            
            i += 1
            if !feedTitles.contains(storeItem.title) && !storeItem.title.contains("Yahoo!ニュース・トピックス") {
                let tempItem = FeedItem(title: storeItem.title, url: storeItem.url, pubDate: storeItem.pubDate, star: false, read: false)
                tempFeedItems.append(tempItem)
            }
            
            if i == storeFeedItem.count {
                feedItems += tempFeedItems
            }
        }
    }
    
    func saveSelected(title: String) {
        
        let predicate = NSPredicate(format: "title == %@", "\(title)")
        let result = realm.objects(RealmFeedItem.self).filter(predicate)
        
        do{
          try realm.write{
              result[0].read = true
          }
        }catch {
          print("Error \(error)")
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
            self.feedItems.append(FeedItem(title: "", url: "", pubDate: "", star: false, read: false))
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
