//
//  ArticleViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit
import WebKit

class ArticleViewController: UIViewController, UINavigationControllerDelegate {
    
    var titleName: String = ""
    var articleUrl: String = ""
    var indexPathRow: Int = 0
    
    let webView = WKWebView()
    
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var starButton: UIButton!
    
    var star: Bool = false {
        didSet {
            if self.star {
                self.starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            } else {
                self.starButton.setImage(UIImage(systemName: "star"), for: .normal)
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
        self.navigationItem.hidesBackButton = true
        
        navigationController?.delegate = self
        
        view.addSubview(tempView)
        tempView.addSubview(webView)
        let request = URLRequest(url: URL(string: "\(articleUrl)")!)
        webView.load(request)
        
        self.star = ArticleModel.shared.fetchStar(title: self.titleName)
    }
    
    @IBAction func backViewAction(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func presentShareSheet(_ sender: Any) {
        
        let activityVC = UIActivityViewController(activityItems: ["\(self.articleUrl)"], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    @IBAction func tapStar(_ sender: Any) {
        
        self.star.toggle()
        
        ArticleModel.shared.saveStar(title: self.titleName)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let controller = viewController as? CollectionViewController {
            controller.filterFeedItems[indexPathRow].star = self.star
        }
    }
}
