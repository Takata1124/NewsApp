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
    
    @IBOutlet weak var appleView: UIView!
    
    private let signInButton = ASAuthorizationAppleIDButton()

    private var errorMessage: String = "" {
        
        didSet {
            errorLabel.isHidden = errorMessage.isEmpty
            errorLabel.text = errorMessage
        }
    }
    
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appleView.addSubview(signInButton)

        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        signInButton.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
    }
    
    private func setupLayout() {
        
        navigationItem.title = "SignUp"
        
        signInButton.addTarget(self, action: #selector(didTapSignUP), for: .touchUpInside)
        
        idTextField.placeholder = "id"
        idTextField.layer.borderColor = UIColor.black.cgColor
        idTextField.layer.borderWidth = 1.0
        idTextField.keyboardType = .numberPad
        
        nameTextField.placeholder = "username"
        nameTextField.layer.borderColor = UIColor.black.cgColor
        nameTextField.layer.borderWidth = 1.0
        
        emailTextField.placeholder = "email"
        emailTextField.layer.borderColor = UIColor.black.cgColor
        emailTextField.layer.borderWidth = 1.0
        
        passwordTextField.placeholder = "password"
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.keyboardType = .numberPad
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
//        self.navigationController?.popViewController(animated: true)
        print("tap")
        
        guard let data: Data = userDefaults.value(forKey: "User") as? Data else { return }
        let user: User = try! JSONDecoder().decode(User.self, from: data)

        print(user)
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
            
            let user: User = User(id: idTextField.text ?? "",
                                  name: nameTextField.text ?? "",
                                  email: emailTextField.text ?? "",
                                  password: passwordTextField.text ?? "",
                                  feed: "")
            
            guard let data: Data = try? JSONEncoder().encode(user) else { return }
            
            userDefaults.setValue(data, forKey: "User")
 
            performSegue(withIdentifier: "goRss", sender: nil)
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

