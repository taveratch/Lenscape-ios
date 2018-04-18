//
//  PhotoInfoViewController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 21/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import Hero
import GoogleMaps
import GooglePlaces

class PhotoInfoViewController: UIViewController, HeroViewControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: Image?
    var uiImage: UIImage?
    @IBOutlet weak var informationWrapper: PhotoInformationCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.hero.id = self.image?.thumbnailLink!
        
        self.setupUI()
        // https://github.com/lkzhao/Hero/issues/187
        self.informationWrapper.hero.modifiers = [.duration(0.4), .translate(y: informationWrapper.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
        setupPhotoInfoCard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupUI() {
        let url = URL(string: image!.link!)
        imageView.kf.setImage(with: url, placeholder: uiImage)
        
        informationWrapper.mapView.isMyLocationEnabled = true
        if image?.location != nil {
            let coordinate = CLLocationCoordinate2D(latitude: (image?.location?.latitude)!, longitude: (image?.location?.longitude)!)
            informationWrapper.mapView.camera = GMSCameraPosition(target: coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
            
            // Add marker to map
            let redMarker = UIImage(named: "Maps Marker")!.withRenderingMode(.alwaysOriginal)
            let markerView = UIImageView(image: redMarker)
            markerView.bounds.size.width = 40
            markerView.bounds.size.height = 40
            let marker = GMSMarker(position: coordinate)
            marker.iconView = markerView
            marker.map = informationWrapper.mapView
        }
    }
    
    private func setupPhotoInfoCard() {
        let profilePictureUrl = URL(string: image!.owner.profilePictureLink)
        informationWrapper.profileImageView.kf.setImage(with: profilePictureUrl)
        
        informationWrapper.pictureNameLabel.text = image!.name!
        informationWrapper.locationNameLabel.text = image!.locationName!
        
        if image!.isNear! {
            var distance = "\(image!.distance!)"
            var unit = "kilometers away"
            if image!.distance! < 1 {
                distance = "\(Int(image!.distance! * 1000))"
                unit = "meters away"
            }
            informationWrapper.distanceLabel.text = distance
            informationWrapper.distanceUnitLabel.text = unit
        }else {
            informationWrapper.distanceLabel.isHidden = true
        }
        
        informationWrapper.likeLabel.text = "\(image!.likes!)"
        informationWrapper.ownerNameLabel.text = image!.owner.name
    }
    
    private func dismissView() {
        Hero.shared.defaultAnimation = .fade
        hero.dismissViewController()
    }
    
    @IBAction func dismissBySwipe(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: nil)
        let progress = translation.y / 2 / view.bounds.height
        
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
            moveTo(view: informationWrapper, x: informationWrapper.frame.origin.x, y: view.bounds.height-200, completion: {
                isFinsihed in
                self.informationWrapper.removeGestureRecognizer(sender)
                // Enable clicking on ImageView
                self.imageView.isUserInteractionEnabled = true
            })
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
    
    private func moveTo(view: UIView, x: CGFloat, y:CGFloat, duration: Double = 0.3, completion: ((Bool) -> Void)? = { isFinished in }) {
        UIView.animate(withDuration: duration, animations: {
            view.frame = CGRect(x: x, y: y, width: view.bounds.width, height: view.bounds.height)
        }, completion: completion)
    }
    
    @IBAction func showMorePhotoDetail(_ sender: UIButton) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(hidePhotoDetail(_:)))
        informationWrapper.addGestureRecognizer(panGesture)
        informationWrapper.isUserInteractionEnabled = true
        moveTo(view: informationWrapper, x: informationWrapper.frame.origin.x, y: 100)
        // Prevent showing Full Image from clicking on ImageView
        imageView.isUserInteractionEnabled = false
        informationWrapper.isHideInfo(hide: false)
    }
}
