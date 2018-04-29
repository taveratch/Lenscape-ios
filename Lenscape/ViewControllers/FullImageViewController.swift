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
    @IBOutlet weak var likeButton: UIButton!
    
    // MARK: - Attributes
    var image: Image!
    var placeHolderImage: UIImage?
    var imageViewHeroId: String?
    var isShowBottomInfo = true {
        didSet {
            showBottomInfo()
        }
    }
    
    // MARK: - ViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initZoomComponent()
        initHeroComponents()
        viewPhoto()
        setupUI()
        
        // https://github.com/lkzhao/Hero/issues/187
        self.infoView.hero.modifiers = [.duration(0.4), .translate(y: infoView.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
        addTapGesture(for: imageView, with: #selector(toggleBottomInfo))
    }
    
    // Before disappear, set back to portrait mode. (See more in AppDelegate)
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIDevice.current.setValue(Int(UIInterfaceOrientation.portrait.rawValue), forKey: "orientation")
        NotificationCenter.default.removeObserver(self, name: .UIDeviceOrientationDidChange, object: nil)
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
        back()
    }
    
    private func viewPhoto() {
        let _ = Api.viewPhoto(photoId: image.id)
    }
    
    @objc private func rotated() {
        showBottomInfo()
    }
    
    @objc private func toggleBottomInfo() {
        isShowBottomInfo = !isShowBottomInfo
    }
    
    @objc private func showBottomInfo() {
        ComponentUtil.fade(of: infoView, hidden: !isShowBottomInfo || UIDevice.current.orientation.isLandscape)
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
        let url = URL(string: (image.link!))
        imageView.kf.setImage(with: url, placeholder: placeHolderImage)
        
        imageNameLabel.text = image.name
        locationNameLabel.text = image.place.name
        setupLikeComponentsUI()
    }
    
    private func setupLikeComponentsUI() {
        likeButton.setImage(UIImage(named: image.is_liked ? "Red heart": "White Heart"), for: .normal)
        numberOfLikeLabel.text = String(image.likes!)
    }
    
    // MARK: - Hero components
    private func initHeroComponents() {
        self.imageView.hero.id = imageViewHeroId == nil ? self.image.thumbnailLink! : imageViewHeroId!
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
        showAlertDialog(message: "Photo has been saved to Camera Roll")
    }
    
    private func deletePhoto() {
        let alert = UIAlertController(title: "Message", message: "Delete this photo?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            action in
            Api.deletePhoto(photoId: self.image.id).done {
                _ in
                self.showAlertDialog(message: "Photo has been deleted") {
                    self.back()
                }
                }.catch {
                    error in
                    let nsError = error as NSError
                    let message = nsError.userInfo["message"] as? String ?? "Error"
                    self.showAlertDialog(title: "Error", message: message)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .destructive))
        present(alert, animated: true)
    }
    
    private func shareToFacebook() {
        let photo = Photo(image: imageView.image!, userGenerated: true)
        let content = PhotoShareContent(photos: [photo])
        do {
            try ShareDialog.show(from: self, content: content)
        } catch {
            showAlertDialog(message: "Something went wrong! Could not find Facebook App")
            print(error)
        }
    }
    
    @IBAction func showMoreActions(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Save Photo", style: .default, handler: {
            action in
            self.savePhotoToCameraRoll()
        }))
        if image.isOwner {
            alert.addAction(UIAlertAction(title: "Delete Photo", style: .destructive, handler: {
                action in
                self.deletePhoto()
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @IBAction func share(_ sender: UIButton) {
        shareToFacebook()
    }
    
    @IBAction func likeImage(_ sender: UIButton) {
        let updateImage = {
            self.image.is_liked = !self.image.is_liked
            self.image.likes! += self.image.is_liked ? 1 : -1
        }
        
        updateImage()
        setupLikeComponentsUI()
        
        Api.likeImage(imageId: image.id, liked: image.is_liked).done { image in
            self.image.is_liked = image.is_liked
            self.image.likes = image.likes
            }.catch { error in
                // Update back to state before press
                updateImage()
                let nsError = error as NSError
                let message = nsError.userInfo["message"] as! String
                self.showAlertDialog(title: "Error", message: "Status code: \(nsError.code). \(message)")
            }.finally {
                self.setupLikeComponentsUI()
        }
    }
}
