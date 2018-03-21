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

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var image: Image?
    var placeHolderImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initZoomComponent()
        initHeroComponents()
        initImageComponent()
    }
    
    @objc func canRotate() -> Void {}

    @IBAction func back(_ sender: UIPanGestureRecognizer) {
        Hero.shared.defaultAnimation = .none
        self.hero.dismissViewController()
    }
    
    
    //Before disappear, set back to portrait mode. (See more in AppDelegate)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (self.isMovingFromParentViewController) {
            UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        }
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
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
