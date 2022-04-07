//
//  SettingViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var settingTableView: UITableView!
    
    let userDefaults = UserDefaults.standard
    let settingList = ["一覧画面表示切り替え","RSS取得間隔","購読RSS管理","文字サイズの変更","ダークモード","ログアウト"]
    var selectCell: String = ""
    
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.separatorColor = UIColor.modeTextColor
        
        navigationItem.title = "設定"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        settingTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goSettingDetail" {
            let settingDetailViewController = segue.destination as! SettingDetailViewController
            settingDetailViewController.selectCell = self.selectCell
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return settingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = settingTableView.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath)
        cell.textLabel?.text = settingList[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(appDelegate.letterSize))
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectCell = settingList[indexPath.row]
        
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
    
    private func selectView(selectCell: String) {
        
        switch selectCell {
            
        case "一覧画面表示切り替え":
            self.performSegue(withIdentifier: "goSettingDetail", sender: nil)
            
        case "RSS取得間隔":
            self.performSegue(withIdentifier: "goSettingDetail", sender: nil)
            
        case "購読RSS管理":
            self.performSegue(withIdentifier: "goSettingDetail", sender: nil)
            
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
