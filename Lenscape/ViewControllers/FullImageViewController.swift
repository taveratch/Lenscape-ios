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
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var likeButton: UIImageView!
    @IBOutlet weak var numberOfLikeLabel: UILabel!
    
    // MARK: - Attributes
    var image: Image?
    var placeHolderImage: UIImage?
    var isShowBottomInfo: Bool = true
    var alwaysHideBottomInfo: Bool = false
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initZoomComponent()
        initHeroComponents()
        setupUI()
        
        // https://github.com/lkzhao/Hero/issues/187
        self.infoView.hero.modifiers = [.duration(0.4), .translate(y: infoView.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
        addGesture(for: imageView, with: #selector(toggleBottomInfo))
    }
    
    // Before disappear, set back to portrait mode. (See more in AppDelegate)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func canRotate() -> Void {}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(rotated),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil
        )
    }

    @IBAction func back(_ sender: UIPanGestureRecognizer) {
        self.back()
    }
    
    @objc private func rotated() {
        if UIDevice.current.orientation.isLandscape {
            alwaysHideBottomInfo = true
            showBottomInfo(isHidden: true, force: true)
        }else {
            alwaysHideBottomInfo = false
            showBottomInfo(isHidden: false, force: true)
        }
    }
    
    private func addGesture(for view: UIView, with action: Selector?) {
        let tap = UITapGestureRecognizer(target: self, action: action)
        view.addGestureRecognizer(tap)
        view.isUserInteractionEnabled = true
    }
    
    @objc private func toggleBottomInfo() {
        showBottomInfo(isHidden: isShowBottomInfo)
        isShowBottomInfo = !isShowBottomInfo
    }
    
    @objc private func showBottomInfo(isHidden: Bool, force: Bool = false) {
        if alwaysHideBottomInfo && !force {
            return
        }
        if isHidden {
            UIView.animate(withDuration: 0.2, animations: {
                self.infoView.alpha = 0
            }) {
                finished in
                self.infoView.isHidden = true
            }
        }else {
            infoView.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.infoView.alpha = 1
            })
        }
    }
    
    func back() {
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        Hero.shared.defaultAnimation = .fade
        dismiss(animated: true)
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        back()
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
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.PhotoInfoViewController.rawValue) as! PhotoInfoViewController
        vc.image = image
        vc.uiImage = placeHolderImage
        vc.hero.modalAnimationType = .fade
        present(vc, animated: true)
    }
    
    private func savePhotoToCameraRoll() {
        UIImageWriteToSavedPhotosAlbum(imageView.image!, nil, nil, nil)
        let alert = UIAlertController(title: nil, message: "Photo has been saved to Camera Roll", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel) {
            action in
            alert.dismiss(animated: true)
        })
        present(alert, animated: true)
    }
    
    @IBAction func showMoreActions(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save Photo", style: .default, handler: {
            action in
            self.savePhotoToCameraRoll()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
}
