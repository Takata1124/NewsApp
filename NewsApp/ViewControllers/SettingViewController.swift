//
//  SettingViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingTable: UITableView!
    
    let systemIcons = ["一覧画面表示切り替え","RSS取得間隔","購読RSS管理","文字サイズの変更","ダークモード"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTable.delegate = self
        settingTable.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return systemIcons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = settingTable.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath)
        cell.textLabel?.text = systemIcons[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goSettingDetail", sender: nil)
    }
}
