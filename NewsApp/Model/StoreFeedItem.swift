//
//  StoreFeedItem.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/10.
//

import Foundation
import RealmSwift

class StoreFeedItem: Object {
    
    @objc dynamic var title = ""
    @objc dynamic var url = ""
    @objc dynamic var pubDate = ""
}
