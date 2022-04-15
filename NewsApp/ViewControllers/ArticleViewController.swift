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
    @IBOutlet weak var starButton: UIButton!
    
    var star: Bool = false {
        didSet {
            if star {
                starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                starButton.setImage(UIImage(systemName: "star"), for: .normal)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        
        webView.frame = tempView.bounds
    }
    
    private func setupLayout() {
        
        navigationItem.title = "\(titleName)"
        //戻るボタンを非表示
        self.navigationItem.hidesBackButton = true
        
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
    
    @IBAction func tapStar(_ sender: Any) {
        
        if self.star {
            self.star = false
        } else {
            self.star = true
        }

        ArticleModel.shared.saveStar(title: self.titleName)
    }
}
