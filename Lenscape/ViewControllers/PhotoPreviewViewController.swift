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
    
    private func setupUI() {
        // If image is in landscape mode then change imageView content mode to aspect fit.
        if image.size.width > image.size.height {
            imageView.contentMode = .scaleAspectFit
        }
        imageView.image = image
    }
    
    /*
     Set orientation back to portrait when leaving this view
    */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /*
     Allow this view to be rotated
     See more: AppDelegate.swift
    */
    @objc func canRotate() -> Void {}

    // MARK: - Initialize zooming feature
    private func initZoomComponent() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapZooming))
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc private func doubleTapZooming() {
        if scrollView.zoomScale != 1.0 {
            scrollView.setZoomScale(4, animated: true)
        }else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    @objc private func back() {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
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
