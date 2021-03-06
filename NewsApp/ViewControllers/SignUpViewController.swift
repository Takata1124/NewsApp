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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var SignUpButton: UIButton!
    @IBOutlet weak var lineView: UIView!
    
    var id: String = ""
    var password: String = ""
    
    private var errorMessage: String = "" {
        
        didSet {
            DispatchQueue.main.async {
                self.errorLabel.isHidden = self.errorMessage.isEmpty
                self.errorLabel.text = self.errorMessage
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        
        SignUpModel.shared.notificationCenter.addObserver(self, selector: #selector(self.handleErrorMessage(_:)), name: Notification.Name(rawValue: SignUpModel.notificationName), object: nil)
    }
    
    @objc func handleErrorMessage(_ notification: Notification) {
        
        if let errormessage = notification.object as? String {
            self.errorMessage = errormessage
        }
    }
    
    private func setupLayout() {
        
        navigationItem.title = "SignUp"
        self.navigationItem.hidesBackButton = true
        
        idTextField.layer.borderWidth = 1.0
        idTextField.keyboardType = .numberPad
        idTextField.accessibilityIdentifier = "idTextField"
        
        passwordTextField.layer.borderWidth = 1.0
        passwordTextField.keyboardType = .numberPad
        passwordTextField.accessibilityIdentifier = "passwordTextField"
        
        SignUpButton.accessibilityIdentifier = "SignUpButton"
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        idTextField.layer.borderColor = UIColor.modeTextColor.cgColor
        passwordTextField.layer.borderColor = UIColor.modeTextColor.cgColor
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goRss" {
            
            let rssView = segue.destination as! RssViewController
            
            rssView.id = SignUpModel.shared.id
            rssView.password = SignUpModel.shared.password
        }
    }
    
    @IBAction func goRssView(_ sender: Any) {
        
        SignUpModel.shared.makingUserData(idText: idTextField.text ?? "", passwordText: passwordTextField.text ?? "") { success in
            
            if success {
                self.performSegue(withIdentifier: "goRss", sender: nil)
            } else {
                print("??????????????????????????????")
            }
        }
    }
}
