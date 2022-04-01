//
//  SignUpViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/01.
//

import UIKit

class SignUpViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "SignUp"
    }
    
    @IBAction func goBackLoginView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goRssView(_ sender: Any) {
        performSegue(withIdentifier: "goRss", sender: nil)
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
