//
//  ExploreViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 6/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Kingfisher

class ExploreViewController: AuthViewController {

    @IBOutlet weak var mapViewImage: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        let user = UserController.getCurrentUser()!
        nameLabel.text = user["name"] as? String
        if let profileImageUrl = user["profilePicture"] as? String {
            let url = URL(string: profileImageUrl)
            profileImage.kf.setImage(with: url)
        }
        
        // Map view : UIImageView
        let tap = UITapGestureRecognizer(target: self, action: #selector(ExploreViewController.showMapView))
        mapViewImage.addGestureRecognizer(tap)
        mapViewImage.isUserInteractionEnabled = true
    }
    
    @objc private func showMapView() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ExploreMapViewController")
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
