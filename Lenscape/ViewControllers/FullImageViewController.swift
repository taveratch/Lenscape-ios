//
//  FullImageViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 21/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero

class FullImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: Image?
    var placeHolderImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.hero.id = self.image?.thumbnailLink!
        let url = URL(string: (image!.link!))
        imageView.kf.setImage(with: url, placeholder: placeHolderImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: UIPanGestureRecognizer) {
        Hero.shared.defaultAnimation = .none
        self.hero.dismissViewController()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
