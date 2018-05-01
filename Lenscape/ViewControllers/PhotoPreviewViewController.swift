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
        addTapGesture(for: backButton, with: #selector(back))
        addTapGesture(for: nextButton, with: #selector(openPhotoPostViewController))
        nextButton.hero.id = "Next"
    }
    
    private func setupUI() {
        // If image is in landscape mode then change imageView content mode to aspect fit.
        if image.size.width > image.size.height {
            imageView.contentMode = .scaleAspectFit
        }
        imageView.image = image
        imageView.hero.id = "PreviewImageView"
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
        scrollView.isZoomable(active: true)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapForZoom(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        scrollView.isUserInteractionEnabled = true
    }
    
    @objc private func doubleTapForZoom(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: scrollView)
        scrollView.doubleTapZoom(pointInView: pointInView)
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
    
}
