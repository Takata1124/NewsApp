//
//  FeedItem.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/03.
//

import Foundation

class FeedItem {
    
    var title: String!
    var url: String!
    var pubDate: String!
    
    init(title: String, url: String, pubDate: String) {
        
        self.title = title
        self.url = url
        self.pubDate = pubDate
    }
}
