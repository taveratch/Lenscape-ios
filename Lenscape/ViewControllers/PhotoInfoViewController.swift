//
//  PhotoInfoViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 21/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class PhotoInfoViewController: UIViewController, HeroViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: Image?
    var uiImage: UIImage?
    @IBOutlet weak var informationWrapper: PhotoInformationCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.hero.id = self.image?.thumbnailLink!
        
        //        https://github.com/lkzhao/Hero/issues/187
        self.informationWrapper.hero.modifiers = [.duration(0.4), .translate(y: informationWrapper.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
        setupPhotoInfoCard()
        self.setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        let url = URL(string: image!.link!)
        imageView.kf.setImage(with: url, placeholder: uiImage)
    }
    
    private func setupPhotoInfoCard() {
        //TODO - Change this
        if let user = UserController.getCurrentUser() {
            let url = URL(string: user["picture"] as! String)
            informationWrapper.profileImageView.kf.setImage(with: url)
        }
        
        // add action to button programmatically
        informationWrapper.moreDetailButton.addTarget(self, action: #selector(showMorePhotoDetail(_:)), for: .touchUpInside)
    }
    
    private func dismissView() {
        Hero.shared.defaultAnimation = .fade
        hero.dismissViewController()
    }
    
    @IBAction func dismissBySwipe(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        let isSwipeTopToBottom = sender.velocity(in: nil).y > 0
        
        switch sender.state {
        case .began:
            dismissView()
        case .changed:
            Hero.shared.update(progress)
            let currentPos = CGPoint(x: informationWrapper.center.x, y: translation.y + informationWrapper.center.y)
            Hero.shared.apply(modifiers: [.position(currentPos)], to: informationWrapper)
        default:
            let velocity = progress + sender.velocity(in: nil).y / view.bounds.height
            if velocity > 0.2 || velocity < -0.2 {
                Hero.shared.finish()
            }else {
                Hero.shared.cancel()
            }
        }
    }
    
    @IBAction func hidePhotoDetail(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        let velocity = progress + sender.velocity(in: nil).y / view.bounds.height
        if velocity > 0.8 {
            moveTo(view: informationWrapper, x: informationWrapper.frame.origin.x, y: view.bounds.height-200)
            informationWrapper.removeGestureRecognizer(sender)
            informationWrapper.moreDetailButton.isHidden = false
        }
    }
    
    @IBAction func dismissByTap(_ sender: UITapGestureRecognizer) {
        dismissView()
    }
    
    @IBAction func showFullImage(_ sender: UITapGestureRecognizer) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
        vc.image = image
        vc.placeHolderImage = uiImage
        vc.hero.modalAnimationType = .auto
        present(vc, animated: true)
    }
    
    private func moveTo(view: UIView, x: CGFloat, y:CGFloat, duration: Double = 0.3) {
        UIView.animate(withDuration: duration, animations: {
            view.frame = CGRect(x: x, y: y, width: view.bounds.width, height: view.bounds.height)
        })
    }
    
    @IBAction func showMorePhotoDetail(_ sender: UIButton) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hidePhotoDetail(_:)))
        informationWrapper.addGestureRecognizer(panGesture)
        informationWrapper.isUserInteractionEnabled = true
        informationWrapper.moreDetailButton.isHidden = true
        moveTo(view: informationWrapper, x: informationWrapper.frame.origin.x, y: 100)
    }
}
