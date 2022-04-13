//
//  RealmFeedItem.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/08.
//

import Foundation
import RealmSwift

class RealmFeedItem: Object {
    
    @objc dynamic var title = ""
    @objc dynamic var url = ""
    @objc dynamic var pubDate = ""
}
