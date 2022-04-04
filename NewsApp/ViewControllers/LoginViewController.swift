//
//  LoginViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/01.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var idTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        idTextfield.delegate = self
    }
    
    private func setupLayout() {
        
        navigationItem.title = "Login"
        
        idTextfield.placeholder = "id"
        idTextfield.layer.borderColor = UIColor.black.cgColor
        idTextfield.layer.borderWidth = 1.0
        
        passwordTextfield.placeholder = "password"
        passwordTextfield.layer.borderColor = UIColor.black.cgColor
        passwordTextfield.layer.borderWidth = 1.0
    }
    
    @IBAction func goListView(_ sender: Any) {
        
        performSegue(withIdentifier: "goList", sender: nil)
    }
    
    @IBAction func goSignUpView(_ sender: Any) {
        performSegue(withIdentifier: "goSignUp", sender: nil)
    }
}
