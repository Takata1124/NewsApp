//
//  SignUpViewController.swift
//  NewsApp
//
//  Created by t032fj on 2022/04/01.
//

import UIKit
import AuthenticationServices

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var id: String = ""
    var name: String = ""
    var email: String = ""
    var password: String = ""
    
    let userDefaults = UserDefaults.standard
    
    @IBOutlet weak var appleView: UIView!
    
    private let signInButton = ASAuthorizationAppleIDButton()
    private var errorMessage: String = "" {
        
        didSet {
            errorLabel.isHidden = errorMessage.isEmpty
            errorLabel.text = errorMessage
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signInButton.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
    }
    
    private func setupLayout() {
        
        navigationItem.title = "SignUp"
        
        signInButton.addTarget(self, action: #selector(didTapSignUP), for: .touchUpInside)
        
        appleView.addSubview(signInButton)
        
        idTextField.placeholder = "id"
        idTextField.layer.borderWidth = 1.0
        idTextField.keyboardType = .numberPad
        
        nameTextField.placeholder = "username"
        nameTextField.layer.borderWidth = 1.0
        
        emailTextField.placeholder = "email"
        emailTextField.layer.borderWidth = 1.0
        
        passwordTextField.placeholder = "password"
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.keyboardType = .numberPad
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        idTextField.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
        nameTextField.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
        emailTextField.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
        passwordTextField.layer.borderColor = UIColor.dynamicColor(light: .black, dark: .white).cgColor
    }
    
    @objc func didTapSignUP() {
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func goBackLoginView(_ sender: Any) {
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return }
        let user: User = try! JSONDecoder().decode(User.self, from: data)
        
        userDefaults.removeObject(forKey: "User")
    }
    
    @IBAction func goRssView(_ sender: Any) {
        
        let idValidator = IdValidator(id: idTextField.text ?? "")
        
        switch idValidator.validate() {
            
        case .none: break
        case .required(_):
            errorMessage = "idを入力してください"
        case .toolong(_):
            errorMessage = "名前は4文字で入力してください"
        }
        
        let nameValidator = NameValidator(name: nameTextField.text ?? "")
        
        switch nameValidator.validate() {
            
        case .none: break
        case .required(_):
            errorMessage = "名前を入力してください"
        case .toolong(_):
            errorMessage = "名前は8文字以内で入力してください"
        }
        
        let emailValidator = EmailAddressValidator(address: emailTextField.text ?? "")
        
        switch emailValidator.validate() {
            
        case .none: break
        case .required(_):
            errorMessage = "メールアドレスを入力してください"
        case .invalidFormat(_):
            errorMessage = "メールアドレスの形式になっていません"
        }
        
        let passwordValidator = PasswordValidator(password: passwordTextField.text ?? "")
        
        switch passwordValidator.validate() {
            
        case .none: break
        case .required(_):
            errorMessage = "パスワードを入力してください"
        case .toolong(_):
            errorMessage = "パスワードは6文字で入力してください"
        }
        
        if idValidator.isValid() && nameValidator.isValid() && emailValidator.isValid() && passwordValidator.isValid() {
            
            self.id = idTextField.text ?? ""
            self.name = nameTextField.text ?? ""
            self.email = emailTextField.text ?? ""
            self.password = passwordTextField.text ?? ""
 
            performSegue(withIdentifier: "goRss", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goRss" {
            let rssView = segue.destination as! RssViewController
            rssView.id = self.id
            rssView.name = self.name
            rssView.email = self.email
            rssView.password = self.password
        }
    }
}

extension SignUpViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        print("failed")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
            
        case let credentials as ASAuthorizationAppleIDCredential:
            
            let userIdetifier = credentials.user
            let firstName: String = (credentials.fullName?.givenName)!
            let lastName: String = (credentials.fullName?.familyName)!
            let fullName = lastName + firstName
            let email = credentials.email
            
            print(userIdetifier)
            print(fullName)
            print(email)
            
            performSegue(withIdentifier: "goRss", sender: nil)
            
            break
            
        default:
            break
        }
    }
}

extension SignUpViewController: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return view.window!
    }
}

