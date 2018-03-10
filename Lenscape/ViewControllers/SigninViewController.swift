//
//  ViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import PromiseKit


class SigninViewController: UIViewController, UITextFieldDelegate {
    
    let fb = FacebookLogin()
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Actions
    @IBAction func facebookLogin(_ sender: UIButton) {
        fb.login(vc: self).done {
            token in //success opening and verifying facebook app.
            Api.signinFacebook(token: token)
                .done { user in
                    self.changeViewController(identifier: Identifier.MainTabBarController.rawValue)
                }.catch { error in
                    fatalError("Failed to authenticate facebook token with lenscape server")
            }
            }.catch { error in }
    }
    
    @IBAction func singin(_ sender: UIButton) {
        // show loading indicator
        signinButton.setTitle("", for: .normal)
        signinButton.loadingIndicator(show: true)
        
        Api.signin(email: emailTextField.text!, password: passwordTextField.text!).done {
            user in
            self.changeViewController(identifier: Identifier.MainTabBarController.rawValue)
            }.catch {
                error in
                
                self.signinButton.setTitle("Sign in", for: .normal)
                self.signinButton.loadingIndicator(show: false)
                
                let alert = UIAlertController(title: "Message", message: error.domain , preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    //MARK: - Delegation actions
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
    
    
    //MARK: - Navigation
    private func changeViewController(identifier: String) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier){
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }

    @IBAction func unwindToSignin(sender: UIStoryboardSegue) {
        
    }
}

