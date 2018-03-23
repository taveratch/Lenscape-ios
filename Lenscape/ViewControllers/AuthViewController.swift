//
//  AuthViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 8/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class AuthViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkAuth()
    }

    // Mark: Navigation
    private func changeViewController(identifier: String) {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: identifier){
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    private func checkAuth() {
        UserController.isLoggedIn().catch { error in
            self.changeViewController(identifier: Identifier.SigninViewController.rawValue)
        }
    }
    
}
