//
//  LoginViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/01.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var user: User?
    private let userDefaults = UserDefaults.standard
    
    private var errorMessage: String = "" {
        
        didSet {
            errorLabel.isHidden = errorMessage.isEmpty
            errorLabel.text = errorMessage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        LoginModel.shared.notificationCenter.addObserver(self, selector: #selector(self.handleErrorMessage(_:)), name: Notification.Name(rawValue: LoginModel.notificationName), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        alreadyUserLogin()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @objc func handleErrorMessage(_ notification: Notification) {
        
        if let errormessage = notification.object as? String {
            self.errorMessage = errormessage
        }
    }
    
    private func setupLayout() {
        
        navigationItem.title = "Login"
        
        idTextField.layer.borderWidth = 1.0
        idTextField.keyboardType = .numberPad
        idTextField.delegate = self
        
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.keyboardType = .numberPad
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        idTextField.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
        passwordTextField.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
    }
    
    private func alreadyUserLogin() {
        
        LoginModel.shared.alreadyConfirmLogin { success in
            if success {
                self.performSegue(withIdentifier: "goCollection", sender: nil)
            } else {
                return
            }
        }
    }

    @IBAction func goListView(_ sender: Any) {
        
        LoginModel.shared.LoginAction(idText: idTextField.text ?? "", passwordText: passwordTextField.text ?? "") { success in
            if success {
                self.performSegue(withIdentifier: "goCollection", sender: nil)
            } else {
                print("Rss選択に移れませんでした")
            }
        }
    }
    
    @IBAction func goSignUpView(_ sender: Any) {
        performSegue(withIdentifier: "goSignUp", sender: nil)
    }
}
