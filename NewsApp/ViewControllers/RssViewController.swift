//
//  RssViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class RssViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let topicModel = TopicModel()

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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goList2" {
            let listView = segue.destination as! ListViewController
            listView.selectFeed = self.selectFeed
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return topicModel.topicArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        cell.textLabel?.text = topicModel.topicArray[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectFeed = topicModel.topicArray[indexPath.row]
        
        let user: User = User(id: self.id, name: self.name, email: self.email, password: self.password, feed: self.selectFeed, login: true)
        
        guard let data: Data = try? JSONEncoder().encode(user) else { return }
        userDefaults.setValue(data, forKey: "User")
        
        self.performSegue(withIdentifier: "goList2", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
