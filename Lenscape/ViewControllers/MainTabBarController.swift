//
//  MainTabBarController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import GoogleMaps

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var currentSelectedIndex: Int = 0
    var sb: UIStoryboard?
    var cameraModal: UIViewController?
    
    private let clLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        sb = UIStoryboard(name: "Main", bundle: nil)
        
        clLocationManager.delegate = self
        clLocationManager.requestWhenInUseAuthorization()
        clLocationManager.startUpdatingLocation()
        
        cameraModal = sb?.instantiateViewController(withIdentifier: Identifier.OpenCameraViewControllerModal.rawValue)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let identifier = viewController.restorationIdentifier ?? ""
        if identifier == Identifier.OpenCameraViewController.rawValue {
            present(cameraModal!, animated: true, completion: nil)
            return false
        }
        
        if selectedViewController == nil || selectedViewController == viewController {
            return false
        }
        
//        // Uncomment this to enable tab changing animation
//        let fromView = selectedViewController!.view!
//        let toView = viewController.view!
//
//        UIView.transition(from: fromView, to: toView, duration: 0.2, options: [.transitionCrossDissolve])
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        //If open camera then SelectedIndex should not be changed
        let identifier = viewController.restorationIdentifier ?? ""
        if identifier != Identifier.OpenCameraViewController.rawValue {
            currentSelectedIndex = tabBarController.selectedIndex
        }
    }

}


//Update current location since app is running
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
        let locationManager = LocationManager.getInstance()
        locationManager.setCurrentLocation(lat: location.coordinate.latitude, long: location.coordinate.longitude)
        clLocationManager.stopUpdatingLocation()
    }
}
