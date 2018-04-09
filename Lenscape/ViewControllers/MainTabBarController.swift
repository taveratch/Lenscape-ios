//
//  MainTabBarController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import GoogleMaps

class MainTabBarController: UITabBarController {
    
    @IBOutlet weak var customTabBar: CustomTabBar!
    
    private var cameraModal: UIViewController?
    private let clLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customTabBar.heroUITabBarDelegate = self
        clLocationManager.delegate = self
        clLocationManager.requestWhenInUseAuthorization()
        
        cameraModal = storyboard?.instantiateViewController(
            withIdentifier: Identifier.OpenCameraViewControllerModal.rawValue
        )
        cameraModal?.loadViewIfNeeded()
    }

}


// Update current location since app is running
extension MainTabBarController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {
            return
        }
        clLocationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        clLocationManager.stopUpdatingLocation()
        let locationManager = LocationManager.getInstance()
        locationManager.setCurrentLocation(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        NotificationCenter.default.post(name: .DidUpdateLocation, object: self)
    }
}

extension MainTabBarController: HeroUITabBarDelegate {
    func onHeroButtonClicked() {
        present(cameraModal!, animated: true)
    }
}
