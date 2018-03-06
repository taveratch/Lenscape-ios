//
//  ViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import PromiseKit
import FacebookLogin
import FBSDKLoginKit


class ViewController: UIViewController, UITextFieldDelegate {
    
    let fb = FacebookLogin()
    
    @IBOutlet weak var passwordTextField: TextField!
    @IBOutlet weak var emailTextField: TextField!
    let api = Api()
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
    
    //Mark: Actions
    @IBAction func facebookLogin(_ sender: UIButton) {
        fb.login(vc: self).done {
            success in //success opening and verifying facebook app.
            // fetch Facebook user data from Facebook app
            self.getFBUserData()
            }.catch { error in
        }
    }
    
    
    //Mark: Delegation actions
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
    
    
    //Mark: Navigation
    private func changeViewController(identifier: String) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier){
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    //Mark: Functions
    func getFBUserData(){
        fb.getFBUserData().done {
            user in
            if UserController.saveUser(user: user) {
                self.changeViewController(identifier: "DashboardViewController")
            }
            }.catch{ error in
                fatalError("Cannot get Facebook user data")
        }
    }
}

