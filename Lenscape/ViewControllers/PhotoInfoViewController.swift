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
    
    var image: Image?
    var uiImage: UIImage?
    @IBOutlet weak var informationWrapper: PhotoInformationCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // https://github.com/lkzhao/Hero/issues/187
        self.informationWrapper.hero.modifiers = [.duration(0.4), .translate(y: informationWrapper.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
        addButtonTarget(for: informationWrapper.closeButton, with: #selector(dismissView))
        self.setupUI()
        setupPhotoInfoCard()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be srecreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private func addButtonTarget(for button: UIButton, with action: Selector?) {
        button.addTarget(self, action: action!, for: .touchUpInside)
    }
    
    private func setupUI() {
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
        
        informationWrapper.dateLabel.text = image!.relativeDatetimeString
    }
    
    @objc private func dismissView() {
        Hero.shared.defaultAnimation = .fade
        hero.dismissViewController()
    }
}
