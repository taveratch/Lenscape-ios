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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.hero.id = self.image?.thumbnailLink!
        
//        https://github.com/lkzhao/Hero/issues/187
        self.informationWrapper.hero.modifiers = [.duration(0.4), .translate(y: informationWrapper.bounds.height), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
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
    
    @IBAction func dismiss(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            Hero.shared.defaultAnimation = .fade
            hero.dismissViewController()
        default:
            Hero.shared.finish()
        }
    }
}
