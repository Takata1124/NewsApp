//
//  RssViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class RssViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let topicModel = TopicModel()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .black
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
        
        print("\(indexPath.row)番目の行が選択されました。")
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goList2", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
