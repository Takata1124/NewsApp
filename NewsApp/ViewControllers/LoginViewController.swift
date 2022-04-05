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
    
    var user: User?
    let userDefaults = UserDefaults.standard
    var userId: String = ""
    var userPassword: String = ""
    
    private var errorMessage: String = "" {
        
        didSet {
            errorLabel.isHidden = errorMessage.isEmpty
            errorLabel.text = errorMessage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        idTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        alreadyUserLogin()
    }
    
    private func alreadyUserLogin() {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else {
            errorMessage = "ユーザー情報がありません"
            return
        }
        self.user = try! JSONDecoder().decode(User.self, from: data)
        self.userId = self.user!.id
        self.userPassword = self.user!.password
        
        if self.user!.login == true {
            performSegue(withIdentifier: "goList", sender: nil)
        }
        else {
            return
        }
    }
    
    private func setupLayout() {
        
        navigationItem.title = "Login"
        
        idTextField.placeholder = "id"
        idTextField.layer.borderColor = UIColor.black.cgColor
        idTextField.layer.borderWidth = 1.0
        
        passwordTextField.placeholder = "password"
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.layer.borderWidth = 1.0
    }

    @IBAction func goListView(_ sender: Any) {
        
        if self.user == nil { return }
        
        let idValidator = IdValidator(id: idTextField.text ?? "")
        
        switch idValidator.validate() {
            
        case .none: break
        case .required(_):
            errorMessage = "idを入力してください"
        case .toolong(_):
            errorMessage = "名前は4文字で入力してください"
        }
        
        let passwordValidator = PasswordValidator(password: passwordTextField.text ?? "")
        
        switch passwordValidator.validate() {
            
        case .none: break
        case .required(_):
            errorMessage = "パスワードを入力してください"
        case .toolong(_):
            errorMessage = "パスワードは6文字で入力してください"
        }
        
        if idValidator.isValid() && passwordValidator.isValid() {
            
            confirmUserLogin(id: idTextField.text!, password: passwordTextField.text!)
        }
    }
    
    private func confirmUserLogin(id: String, password: String) {
        
        if userId != id {
            errorMessage = "idが違います"
            print("idが違います")
        }
        
        if userPassword != password {
            errorMessage = "passwordが違います"
            print("passwordが違います")
        }
        
        if userId == id && userPassword == password {
            
            let recodeUser: User = User(id: self.user!.id, name: self.user!.name, email: self.user!.email, password: self.user!.password, feed: self.user!.feed, login: true)
            guard let data: Data = try? JSONEncoder().encode(recodeUser) else { return }
            userDefaults.setValue(data, forKey: "User")
            performSegue(withIdentifier: "goList", sender: nil)
        }
    }
    
    @IBAction func goSignUpView(_ sender: Any) {
        performSegue(withIdentifier: "goSignUp", sender: nil)
    }
}
