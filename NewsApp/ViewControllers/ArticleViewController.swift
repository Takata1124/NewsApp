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
        
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        
        webView.frame = tempView.bounds
    }
    
    private func setupLayout() {
        
        navigationItem.title = "\(titleName)"
        
        view.addSubview(tempView)
        tempView.addSubview(webView)

        let request = URLRequest(url: URL(string: "\(articleUrl)")!)
        webView.load(request)
    }
    
    @IBAction func backViewAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func presentShareSheet(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: ["\(articleUrl)"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
}
