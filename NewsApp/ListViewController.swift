//
//  ListViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class ListViewController: UIViewController, XMLParserDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var parser: XMLParser?
    
    let xmlUrl: String = "https://news.yahoo.co.jp/rss/topics/top-picks.xml"
    var feedItems = [FeedItem]()
    var currrentElementName: String?
    
    let item_name = "item"
    let title_name = "title"
    let link_name  = "link"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getXMLData(urlString: xmlUrl)
    }
    
    private func getXMLData(urlString: String) {
        
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
    
    func parserDidStartDocument(_ parser: XMLParser) {
        print("XML解析開始しました")
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        self.currrentElementName = nil

        if elementName == item_name {
            self.feedItems.append(FeedItem())
        } else {
            currrentElementName = elementName
        }
        
        print("開始タグ:" + elementName)
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        print("要素:" + string)
        
        if self.feedItems.count > 0 {
            
            let lastItem = self.feedItems[self.feedItems.count - 1]
            
            switch self.currrentElementName {
                
            case title_name:
                let tempString = lastItem.title
                lastItem.title = (tempString != nil) ? tempString! + string:  string
                
            case link_name:
                lastItem.url = string
                
            default: break
                
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        self.currrentElementName = nil
        print("終了タグ:" + elementName)
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print("エラー:" + parseError.localizedDescription)
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        print("reload table")
        print(feedItems.count)
        print(feedItems[0].title)
        
        self.tableView.reloadData()
    }
}

class FeedItem {
    
    var title: String!
    var url: String!
}
