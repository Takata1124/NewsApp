//
//  RssViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class RssViewController: UIViewController {

    var id: String = ""
    var password: String = ""
    var selectFeed: String = ""
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var accessTokenValue: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "RSS"
        //戻るボタン非表示
        self.navigationItem.hidesBackButton = true
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .black
    }
}

extension RssViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return RssModel.shared.rssArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = RssModel.shared.rssArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        RssModel.shared.saveUseData(id: self.id, password: self.password, accessTokeValue: self.accessTokenValue, indexPath: indexPath) { success in
            
            if success {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goCollection", sender: nil)
                }
            } else {
                print("Rssの登録に失敗しました")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
