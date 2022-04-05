//
//  SettingViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingTable: UITableView!
    
    let userDefaults = UserDefaults.standard
    let systemIcons = ["一覧画面表示切り替え","RSS取得間隔","購読RSS管理","文字サイズの変更","ダークモード","ログアウト"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTable.delegate = self
        settingTable.dataSource = self
        settingTable.separatorColor = UIColor.modeTextColor
        
        navigationItem.title = "設定"
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
        
        let selectCell = systemIcons[indexPath.row]
        print(selectCell)
        
        selectView(selectCell: selectCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func recodeUserdefaults() {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return }
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        let recodeUser: User = User(id: user.id, name: user.name, email: user.email, password: user.password, feed: user.feed, login: false)
        guard let data: Data = try? JSONEncoder().encode(recodeUser) else { return }
        userDefaults.setValue(data, forKey: "User")
    }
    
//    let systemIcons = ["一覧画面表示切り替え","RSS取得間隔","購読RSS管理","文字サイズの変更","ダークモード","ログアウト"]
    
    private func selectView(selectCell: String) {
        
        switch selectCell {
            
        case "文字サイズの変更":
            self.performSegue(withIdentifier: "goSettingDetail", sender: nil)
            
        case "ダークモード":
            self.performSegue(withIdentifier: "goSettingDetail", sender: nil)
            
        case "ログアウト":
            recodeUserdefaults()
            self.navigationController?.popToRootViewController(animated: true)
            
        default:
            print("default")
        }
    }
}
