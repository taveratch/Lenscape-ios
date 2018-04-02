//
//  PhotoPreviewViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 2/4/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit

class PhotoPreviewViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var nextButton: ShadowView!
    
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        initZoomComponent()
        setupBackButton()
        setupNextButton()
        nextButton.hero.id = "Next"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func setupUI() {
        imageView.image = image
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Before disappear, set back to portrait mode. (See more in AppDelegate)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    @objc func canRotate() -> Void {}

    // MARK: - Initialize zooming feature
    private func initZoomComponent() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc private func back() {
        dismiss(animated: true)
    }
    
    @objc private func openPhotoPostViewController() {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.PhotoPostViewController.rawValue) as? PhotoPostViewController else {
            fatalError("identifier: \(Identifier.PhotoPostViewController.rawValue) is not type of PhotoPostViewController")
        }
        vc.image = image
        present(vc, animated: true)
        
    }
    
    private func setupBackButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(back))
        backButton.addGestureRecognizer(tap)
        backButton.isUserInteractionEnabled = true
    }
    
    private func setupNextButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(openPhotoPostViewController))
        nextButton.addGestureRecognizer(tap)
        nextButton.isUserInteractionEnabled = true
    }
    
}
