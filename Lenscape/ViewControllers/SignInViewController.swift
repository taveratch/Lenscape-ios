//
//  ViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import PromiseKit


class SignInViewController: UIViewController {
    
    // MARK: - Attributes
    
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    
    private let fb = FacebookLogin()
    
    // MARK: - ViewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.navigationController?.isNavigationBarHidden = true
    }
    
    // MARK: - Actions
    @IBAction func facebookLogin(_ sender: UIButton) {
        facebookButton.setTitle("", for: .normal)
        facebookButton.loadingIndicator(show: true)
        
        fb.login(vc: self).done {
            token in //success opening and verifying facebook app.
            Api.signInFacebook(token: token)
                .done { user in
                    self.facebookButton.setTitle("Facebook", for: .normal)
                    self.facebookButton.loadingIndicator(show: false)
                    
                    UserController.saveUser(user: user)
                    self.changeViewController(identifier: Identifier.MainTabBarController.rawValue)
                }.catch { error in
                    print(error)
                    fatalError("Failed to authenticate facebook token with lenscape server")
            }
            }.catch { error in
                self.facebookButton.setTitle("Facebook", for: .normal)
                self.facebookButton.loadingIndicator(show: false)
        }
    }
    
    @IBAction func signIn(_ sender: UIButton) {
        // show loading indicator
        signinButton.setTitle("", for: .normal)
        signinButton.loadingIndicator(show: true)
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            Api.signIn(email: email, password: password).done { user in
                UserController.saveUser(user: user)
                self.changeViewController(identifier: Identifier.MainTabBarController.rawValue)
                }.catch {
                    error in
                    let nsError = error as NSError
                    let message = nsError.userInfo["message"] as! String
                    self.signinButton.setTitle("Sign in", for: .normal)
                    self.signinButton.loadingIndicator(show: false)
                    
                    let alert = UIAlertController(title: "Message", message: message , preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
            }
        }
    }
    
    // MARK: - Navigation
    private func changeViewController(identifier: String) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier){
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func unwindToSignin(sender: UIStoryboardSegue) {
        
    }
}

// MARK: - UITextFieldDelegate

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Hide keyboard when touch outside textfields
        self.view.endEditing(true)
    }
    
}

