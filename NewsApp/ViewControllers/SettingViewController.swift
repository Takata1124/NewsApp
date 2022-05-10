//
//  SettingViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/02.
//

import UIKit
import PKHUD

class SettingViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var settingTableView: UITableView!
    
    var selectCell: String = ""
    let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var deleteAction: Bool = false
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "設定"
        
        settingTableView.delegate = self
        settingTableView.dataSource = self
        settingTableView.separatorColor = UIColor.modeTextColor
        
        navigationController?.delegate = self
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
    
    private func UserLogout(completion: @escaping() -> Void) {
        
        SettingModel.shared.UserLogout { isLogout in
            if isLogout {
                completion()
            }
        }
    }
    
    private func selectView(selectCell: String) {
        
        switch selectCell {
            
        case "記事データの削除":
            SettingModel.shared.deleteArticleData {
                self.deleteAction = true
                self.navigationController?.popViewController(animated: true)
            }
    
        case "購読データの削除":
            SettingModel.shared.deleteSubscriptionData {
                self.navigationController?.popViewController(animated: true)
            }

        case "ログアウト":
            UserLogout {
                HUD.show(.progress, onView: self.view)
                DispatchQueue.main.asyncAfter(deadline: .now() + 7, execute: {
                    self.navigationController?.popToRootViewController(animated: true)
                    HUD.hide()
                })
            }
            
        default:
            self.performSegue(withIdentifier: "goSettingDetail", sender: nil)
        }
    }

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        if let controller = viewController as? CollectionViewController {
            controller.deleteAction = self.deleteAction
        }
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return SettingModel.settingList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = settingTableView.dequeueReusableCell(withIdentifier: "settingTableViewCell", for: indexPath)
        cell.textLabel?.text = SettingModel.settingList[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: CGFloat(appDelegate.letterSize))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.selectCell = SettingModel.settingList[indexPath.row]
        selectView(selectCell: selectCell)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
