//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController {
    
    var titleName: String = ""
    var articleUrl: String = ""
    let webView = WKWebView()
    
    @IBOutlet weak var tempView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "\(titleName)"
        
        view.addSubview(tempView)
        tempView.addSubview(webView)
//
        let request = URLRequest(url: URL(string: "\(articleUrl)")!)
        webView.load(request)
    }
    
    override func viewDidLayoutSubviews() {
        
        webView.frame = tempView.bounds
    }
}
