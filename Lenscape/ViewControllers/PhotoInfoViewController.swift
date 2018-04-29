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
    @IBOutlet weak var infoWrapper: UIView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var profileImageView: EnhancedUIImage!
    @IBOutlet weak var pictureNameLabel: UILabel!
    @IBOutlet weak var locationNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    @IBOutlet weak var distanceStackView: UIStackView!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var ownerNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var takenDateLabel: UILabel!
    @IBOutlet weak var takenTimeLabel: UILabel!
    @IBOutlet weak var seasonLabel: UILabel!
    @IBOutlet weak var viewsLabel: UILabel!
    @IBOutlet weak var openGoogleMapsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // https://github.com/lkzhao/Hero/issues/187
        self.infoWrapper.hero.modifiers = [.duration(0.4), .translate(y: infoWrapper.bounds.height*2), .beginWith([.zPosition(10)]), .useGlobalCoordinateSpace]
        
        addButtonTarget(for: closeButton, with: #selector(dismissView))
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
    
    private func isGoogleMapsAppAvailable() -> Bool {
        return UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!)
    }
    
    private func setupUI() {
        mapView.isMyLocationEnabled = true
        let coordinate = CLLocationCoordinate2D(latitude: (image?.place.location.latitude)!, longitude: (image?.place.location.longitude)!)
        mapView.camera = GMSCameraPosition(target: coordinate, zoom: 17, bearing: 0, viewingAngle: 0)
        
        // Add marker to map
        let redMarker = UIImage(named: "Maps Marker")!.withRenderingMode(.alwaysOriginal)
        let markerView = UIImageView(image: redMarker)
        markerView.bounds.size.width = 40
        markerView.bounds.size.height = 40
        let marker = GMSMarker(position: coordinate)
        marker.iconView = markerView
        marker.map = mapView
    }
    
    private func setupPhotoInfoCard() {
        let profilePictureUrl = URL(string: image!.owner.profilePictureLink)
        profileImageView.kf.setImage(with: profilePictureUrl)
        
        pictureNameLabel.text = image!.name!
        locationNameLabel.text = image!.place.name
        if image!.isNear != nil, image!.isNear! {
            var distance = String(format: "%.2f", image!.distance!)
            var unit = "km away"
            if image!.distance! < 1 {
                distance = "\(Int(image!.distance! * 1000))"
                unit = "meters away"
            }
            distanceLabel.text = distance
            distanceUnitLabel.text = unit
        } else {
            distanceStackView.isHidden = true
        }
        
        likeLabel.text = "\(image!.likes!)"
        ownerNameLabel.text = image!.owner.name
        
        dateLabel.text = image!.relativeDatetimeString
        
        takenDateLabel.text = image!.dateTakenString
        takenTimeLabel.text = image!.partOfDayString
        
        seasonLabel.text = image!.seasonString
        
        if image!.views > 1000 {
            viewsLabel.text = String(format: "%.1f k", image!.views)
        } else {
            viewsLabel.text = String(image!.views)
        }
    }
    
    @objc private func dismissView() {
        Hero.shared.defaultAnimation = .fade
        hero.dismissViewController()
    }
    
    @IBAction func openGoogleMaps(_ sender: UIButton) {
        let place = image!.place
        if isGoogleMapsAppAvailable() {
            UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(place.location.latitude),\(place.location.longitude)&directionsmode=driving")!)
        }else {
            UIApplication.shared.open(URL(string: "https://www.google.com/maps/search/?api=1&query=\(place.location.getLatlongFormat())")!)
        }
    }
}
