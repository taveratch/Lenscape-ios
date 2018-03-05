//
//  ViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 4/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    let api = Api()
    override func viewDidLoad() {
        super.viewDidLoad()
        signin()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func signin() {
        api.signin(email: "taweesoft@gmail.com", password: "hello").done { user in
            self.genderLabel.text = user["gender"] as? String
            self.emailLabel.text = user["email"] as? String
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

