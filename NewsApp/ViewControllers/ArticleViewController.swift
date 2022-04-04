//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController {
    
    var articleUrl: String = ""
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.frame)
        view.addSubview(webView)
   
        let request = URLRequest(url: URL(string: "\(articleUrl)")!)
        webView.load(request)
    }
}
