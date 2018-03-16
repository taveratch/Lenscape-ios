//
//  PhotoPostViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 12/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Alamofire

class PhotoPostViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    private func setupUI() {
        imageView.image = image
    }
    
    // Hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func back(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Cancel", message: "Cancel sharing photo?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            self.performSegue(withIdentifier: "unwindToCamera", sender: self)
            //            self.navigationController?.popViewController(animated: true)
            //            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func closeMe() {
        let mainTabBarViewController = self.tabBarController as? MainTabBarController
        mainTabBarViewController?.selectedIndex = (mainTabBarViewController?.currentSelectedIndex)!
        dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        shareButton.isEnabled = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.MainTabBarController.rawValue)
        self.navigationController?.pushViewController(vc!, animated: true)
//        self.performSegue(withIdentifier: "unwindToExplore", sender: self)
//        self.closeMe()
//        if let data = UIImageJPEGRepresentation(image!,1) {
//            Api.uploadImage(data: data).done {
//                response in
//                print(response)
//                }.catch { error in
//                    print(error)
//            }
//        }
    }
}