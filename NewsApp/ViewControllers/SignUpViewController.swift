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
        
        emailTextField.placeholder = "email"
        emailTextField.layer.borderColor = UIColor.black.cgColor
        emailTextField.layer.borderWidth = 1.0
        
        passwordTextField.placeholder = "password"
        passwordTextField.layer.borderColor = UIColor.black.cgColor
        passwordTextField.layer.borderWidth = 1.0
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
    
    @IBAction func goBackLoginView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goRssView(_ sender: Any) {
        
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
            errorMessage = "パスワードは6文字以内で入力してください"
        }
        
        if emailValidator.isValid() && passwordValidator.isValid() {
            
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

