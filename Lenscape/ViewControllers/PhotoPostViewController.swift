//
//  PhotoPostViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 12/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class PhotoPostViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
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
            self.navigationController?.popViewController(animated: true)
//            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
