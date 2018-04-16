//
//  FullImageViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 21/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class FullImageViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - UI Components
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var closeButton: UIView!
    
    // MARK: - Attributes
    var image: Image?
    var placeHolderImage: UIImage?
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initZoomComponent()
        initHeroComponents()
        initImageComponent()
        setupCloseButton()
    }
    
    // Before disappear, set back to portrait mode. (See more in AppDelegate)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParentViewController {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
    }
    
    
    @objc func canRotate() -> Void {}

    @IBAction func back(_ sender: UIPanGestureRecognizer) {
        self.back(recognizer: nil)
    }
    
    @objc func back(recognizer: UITapGestureRecognizer?) {
        Hero.shared.defaultAnimation = .none
        self.hero.dismissViewController()
    }
    
    private func setupCloseButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(back(recognizer:)))
        closeButton.addGestureRecognizer(tap)
        closeButton.isUserInteractionEnabled = true
    }
    

    // MARK: - Initialize Image Component
    private func initImageComponent() {
        let url = URL(string: (image!.link!))
        imageView.kf.setImage(with: url, placeholder: placeHolderImage)
    }
    
    // MARK: - Hero components
    private func initHeroComponents() {
        self.imageView.hero.id = self.image?.thumbnailLink!
    }
    
    // MARK: - Initialize zooming feature
    private func initZoomComponent() {
        scrollView.delegate = self
        scrollView.isZoomable(active: true)
        
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapToZoom(recognizer:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
    }
    
    @objc private func doubleTapToZoom(recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: scrollView)
        scrollView.doubleTapZoom(pointInView: pointInView)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
