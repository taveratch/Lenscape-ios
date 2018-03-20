//
//  ProfileViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 8/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    // MARK: - Attributes
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var profilePicture: EnhancedUIImage!
    @IBOutlet weak var info: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadUserData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func showSettingsMenu(_ sender: UIButton) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private Methods
    private func loadUserData() {
        if let user = UserController.getCurrentUser() {
            let name = "\(user["firstname"] ?? "") \(user["lastname"] ?? "")"
            fullName.text = name
            info.text = user["email"] as? String
            if let url = user["picture"] as? String {
                profilePicture.kf.setImage(with: URL(string: url))
            }
        }
    }

}
