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
    @IBOutlet weak var informationWrapper: UIView!
    
    @IBOutlet weak var profileImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.hero.id = self.image?.thumbnailLink!
        
        //        https://github.com/lkzhao/Hero/issues/187
        self.informationWrapper.hero.modifiers = [.duration(0.4), .translate(y: informationWrapper.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        self.setupUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        let url = URL(string: image!.link!)
        imageView.kf.setImage(with: url, placeholder: uiImage)
        
        //TODO - Change this
        if let user = UserController.getCurrentUser() {
            let url = URL(string: user["picture"] as! String)
            profileImage.kf.setImage(with: url)
        }
    }
    
    private func dismissView() {
        Hero.shared.defaultAnimation = .fade
        hero.dismissViewController()
    }
    
    @IBAction func dismissBySwipe(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        let isSwipeTopToBottom = sender.velocity(in: nil).y > 0
        
        if !isSwipeTopToBottom {
            return
        }
        
        switch sender.state {
        case .began:
            dismissView()
        case .changed:
            Hero.shared.update(progress)
            let currentPos = CGPoint(x: informationWrapper.center.x, y: translation.y + informationWrapper.center.y)
            Hero.shared.apply(modifiers: [.position(currentPos)], to: informationWrapper)
        default:
            if progress + sender.velocity(in: nil).y / view.bounds.height > 0.2 {
                Hero.shared.finish()
            }else {
                Hero.shared.cancel()
            }
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
}
