//
//  ListViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit
import RealmSwift

class ListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var parser: XMLParser?
    
    var selectFeed: String = ""
    var articleUrl: String = ""
    
    var feedUrl: String = ""
    var feedItems = [FeedItem]()
    var currrentElementName: String?
    
    let item_name = "item"
    let title_name = "title"
    let link_name  = "link"
    
    let userDefaults = UserDefaults.standard
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = UIColor.modeTextColor
        
        setupLayout()
        
        usergetFeed()
        getFeedUrl(self.selectFeed)
        getXMLData(urlString: feedUrl)
    }
    
    private func setupLayout() {
        
        navigationItem.title = "一覧"
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
    
    @IBAction func goSettingView(_ sender: Any) {
        
        self.performSegue(withIdentifier: "goSetting", sender: nil)
    }
}

extension ListViewController: XMLParserDelegate {
    
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
        
        self.tableView.reloadData()
    }
}


extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        if let celltext = feedItems[indexPath.row].title {
            cell.textLabel?.text = celltext
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.articleUrl = feedItems[indexPath.row].url
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goArticle", sender: nil)
    }
}
