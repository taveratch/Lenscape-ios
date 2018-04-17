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
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var likeButton: UIImageView!
    @IBOutlet weak var numberOfLikeLabel: UILabel!
    
    // MARK: - Attributes
    var image: Image?
    var placeHolderImage: UIImage?
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initZoomComponent()
        initHeroComponents()
        setupUI()
        setupCloseButton()
        
        // https://github.com/lkzhao/Hero/issues/187
        self.infoView.hero.modifiers = [.duration(0.4), .translate(y: infoView.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
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
        Hero.shared.defaultAnimation = .fade
        dismiss(animated: true)
    }
    
    private func setupCloseButton() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(back(recognizer:)))
        closeButton.addGestureRecognizer(tap)
        closeButton.isUserInteractionEnabled = true
    }
    

    // MARK: - Initialize Image Component
    private func setupUI() {
        let url = URL(string: (image!.link!))
        imageView.kf.setImage(with: url, placeholder: placeHolderImage)
        
        imageNameLabel.text = image!.name
        locationNameLabel.text = image!.locationName
        numberOfLikeLabel.text = String(image!.likes!)
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
    
    @IBAction func seeMore(_ sender: UIButton) {
    }
}
