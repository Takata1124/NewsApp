//
//  RssViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class RssViewController: UIViewController {

    let rssArray :[String] = ["主要","国内","国際","経済","エンタメ","スポーツ","IT","科学","地域"]

    var id: String = ""
    var name: String = ""
    var email: String = ""
    var password: String = ""
    var selectFeed: String = ""
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .black
    }
}

extension RssViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rssArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = rssArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectFeed = rssArray[indexPath.row]
        let user: User = User(id: self.id, name: self.name, email: self.email, password: self.password, feed: self.selectFeed, login: true)
        
        guard let data: Data = try? JSONEncoder().encode(user) else { return }
        userDefaults.setValue(data, forKey: "User")
        
        self.performSegue(withIdentifier: "goCollection", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
