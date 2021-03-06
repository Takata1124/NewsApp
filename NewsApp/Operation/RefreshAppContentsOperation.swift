//
//  RefreshAppContentsOperation.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/10.
//

import Foundation
import RealmSwift

protocol getXMLDataProtocol {
    
    func getXMLData(urlString: String)
}

class getXMLDataOperation: Operation, XMLParserDelegate {
    
    private var currrentElementName: String?
    private var userDefaults: UserDefaults?
    
    let usernotificationCenter = UNUserNotificationCenter.current()
    var window: UIWindow?
    
    private var feedUrl: String = ""
    private var feedItems = [FeedItem]()
    private var selectFeed: String = ""
    
    private let item_name = "item"
    private let title_name = "title"
    private let link_name  = "link"
    private let pubDate_name = "pubDate"
  
    private var parser: XMLParser?
    
    init(userDefaults: UserDefaults = UserDefaults.standard) {
        
        self.userDefaults = userDefaults
    }
    
    override func main() {
        
        self.usergetFeed()
        self.getFeedUrl(self.selectFeed)
        
        self.getXMLData(urlString: self.feedUrl)
        self.saveXMLData(feeditems: self.feedItems)
    }
    
    private func usergetFeed() {
        
        if let data: Data = userDefaults?.value(forKey: "User") as? Data {
            let user: User = try! JSONDecoder().decode(User.self, from: data)
            self.selectFeed = user.feed
        }
    }
    
    func getXMLData(urlString: String) {
        
        guard let url = URL(string: urlString) else {
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
                lastItem.title = (tempString != nil) ? tempString! + string:  string
                
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
    
    func parserDidEndDocument(_ parser: XMLParser) {}
    
    private func saveXMLData(feeditems: [FeedItem]) {
        
        var temporaryFeedItem: [FeedItem] = []
        temporaryFeedItem += feeditems

        if let data = userDefaults?.data(forKey: "StoreFeedItems") {
        
            if let storeData = try? JSONDecoder().decode([FeedItem].self, from: data) {
                temporaryFeedItem += storeData
            }
        }

        if let data = try? JSONEncoder().encode(temporaryFeedItem) {
            
            userDefaults?.set(data, forKey: "StoreFeedItems")
        }
    }
}
