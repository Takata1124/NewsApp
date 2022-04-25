//
//  LoginViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/01.
//

import UIKit
import LineSDK

class LoginViewController: UIViewController, UITextFieldDelegate, LoginButtonDelegate {
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var defaultLoginButton: UIButton!
    @IBOutlet weak var transSignUpButton: UIButton!
    
    private let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    private var user: User?
    
    private var errorMessage: String = "" {
        didSet {
            errorLabel.isHidden = errorMessage.isEmpty
            errorLabel.text = errorMessage
        }
    }
    
    private var accessTokenValue: String = ""
    
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
        idTextField.accessibilityIdentifier = "idTextField"
        
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.keyboardType = .numberPad
        passwordTextField.accessibilityIdentifier = "passwordTextField"
        
        defaultLoginButton.accessibilityIdentifier = "defaultLoginButton"
        
        transSignUpButton.accessibilityIdentifier = "transSignUpButton"
        
        let lineLoginButton = LoginButton()
        lineLoginButton.delegate = self
        lineLoginButton.permissions = [.profile]
        lineLoginButton.presentingViewController = self
        lineLoginButton.accessibilityIdentifier = "lineButton"

        lineView.addSubview(lineLoginButton)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        idTextField.layer.borderColor = UIColor.modeTextColor.cgColor
        passwordTextField.layer.borderColor = UIColor.modeTextColor.cgColor
    }
    
    private func alreadyUserLogin() {
        
        LoginModel.shared.alreadyConfirmLogin { success in
            
            if success {
                self.performSegue(withIdentifier: "goCollection", sender: nil)
                return
            }
            return
        }
    }
    
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        print("LINE認証成功")
        print("アクセストークン:\(loginResult.accessToken.value)")
        print("ここでログイン処理を呼び出す")
        
        print(loginResult.userProfile?.userID ?? "")
        
        self.accessTokenValue = loginResult.userProfile!.userID
        
        LoginModel.shared.lineLoginAction(accessToken: accessTokenValue) { success in
            
            if success {
                self.performSegue(withIdentifier: "goCollection", sender: nil)
                return
            }
            
            self.performSegue(withIdentifier: "LineToRss", sender: nil)
        }
    }
    
    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        print("Error: \(error)")
    }
    
    func loginButtonDidStartLogin(_ button: LoginButton) {
        print("Login Started.")
    }
    
    @IBAction func goListView(_ sender: Any) {
        
        LoginModel.shared.LoginAction(idText: idTextField.text ?? "", passwordText: passwordTextField.text ?? "") { success in
            if success {
                self.performSegue(withIdentifier: "goCollection", sender: nil)
                return
            }

            print("Rss選択に移れませんでした")
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LineToRss" {
            let rssViewController = segue.destination as! RssViewController
            
            rssViewController.accessTokenValue = self.accessTokenValue
        }
    }
    
    @IBAction func goSignUpView(_ sender: Any) {
        performSegue(withIdentifier: "goSignUp", sender: nil)
    }
}
