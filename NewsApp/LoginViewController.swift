//
//  LoginViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/01.
//

import UIKit

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Login"
    }
    
    @IBAction func goListView(_ sender: Any) {
        performSegue(withIdentifier: "goList", sender: nil)
    }

    @IBAction func goSignUpView(_ sender: Any) {
        performSegue(withIdentifier: "goSignUp", sender: nil)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
