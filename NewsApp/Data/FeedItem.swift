//
//  FeedItem.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/03.
//

import Foundation

class FeedItem: Equatable {
    
    static func == (lhs: FeedItem, rhs: FeedItem) -> Bool {
        return lhs.title == rhs.title
    }

    var title: String!
    var url: String!
    var pubDate: String!
    var star: Bool!
    var read: Bool!
    var afterRead: Bool!
    
    init(title: String, url: String, pubDate: String, star: Bool, read: Bool, afterRead: Bool) {
        
        self.title = title
        self.url = url
        self.pubDate = pubDate
        self.star = star
        self.read = read
        self.afterRead = afterRead
    }
}
