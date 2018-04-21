//
//  FullImageViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 21/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero
import FacebookShare

class FullImageViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - UI Components
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var imageNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
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
        
        ComponentUtil.addTapGesture(parentViewController: self, for: imageView, with: #selector(toggleBottomInfo))
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
    
    @objc private func toggleBottomInfo() {
        showBottomInfo(isHidden: isShowBottomInfo)
        isShowBottomInfo = !isShowBottomInfo
    }
    
    @objc private func showBottomInfo(isHidden: Bool, force: Bool = false) {
        if alwaysHideBottomInfo && !force {
            return
        }
        ComponentUtil.fade(of: infoView, hidden: isHidden)
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
        setupLikeComponentsUI()
    }
    
    private func setupLikeComponentsUI() {
        LikeButton.setImage(UIImage(named: image!.is_liked ? "Red heart": "Gray Heart"), for: .normal)
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
        AlertController.showAlert(viewController: self, title: nil, message: "Photo has been saved to Camera Roll")
    }
    
    private func shareToFacebook() {
        let photo = Photo(image: imageView.image!, userGenerated: true)
        let content = PhotoShareContent(photos: [photo])
        do {
            try ShareDialog.show(from: self, content: content)
        }catch {
            AlertController.showAlert(viewController: self, message: "Something went wrong!. Could not find Facebook App")
            print(error)
        }
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
    
    @IBAction func share(_ sender: UIButton) {
        shareToFacebook()
    }
    
    @IBAction func likeImage(_ sender: UIButton) {
        let updateImage = {
            self.image!.is_liked = !self.image!.is_liked
            self.image!.likes! += self.image!.is_liked ? 1 : -1
        }
        
        updateImage()
        setupLikeComponentsUI()
       
        let _ = Api.likeImage(imageId: image!.id).done {
            image in
            self.image!.is_liked = image.is_liked
            self.image!.likes = image.likes
            }.catch {
                error in
                //Update back to state before press
                updateImage()
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as! String
                AlertController.showAlert(viewController: self, title: "Error", message: "Status code: \(nsError.code). \(message)")
            }
            .finally {
                self.setupLikeComponentsUI()
        }
    }
}
