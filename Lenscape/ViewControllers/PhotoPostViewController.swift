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
    let photoUploader = PhotoUploader()
    
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
            self.performSegue(withIdentifier: "unwindToCameraAndDisiss", sender: self)
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
        if let data = UIImageJPEGRepresentation(image!,1) {
            print(data.description)
            // the data can be passed to ExploreViewController via UserDefaults
            UserDefaults.standard.set(data, forKey: "uploadPhotoData")
            self.performSegue(withIdentifier: "unwindToCameraAndDisiss", sender: self)
        }
    }
}
