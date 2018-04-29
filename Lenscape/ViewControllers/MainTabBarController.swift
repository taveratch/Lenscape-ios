//
//  MainTabBarController.swift
//  Lenscape
//
//  Created by TAWEERAT CHAIMAN on 9/3/2561 BE.
//  Copyright © 2561 Lenscape. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications
import SwiftyJSON

class MainTabBarController: UITabBarController, UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var customTabBar: CustomTabBar!
    
    private var cameraModal: UIViewController?
    private let clLocationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customTabBar.heroUITabBarDelegate = self
        clLocationManager.delegate = self
        clLocationManager.requestWhenInUseAuthorization()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(
            options: [.alert, .badge, .sound],
            completionHandler: {_, _ in }
        )
        UIApplication.shared.registerForRemoteNotifications()
        
        cameraModal = storyboard?.instantiateViewController(
            withIdentifier: Identifier.OpenCameraViewControllerModal.rawValue
        )
        cameraModal?.loadViewIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCurrentLocation), name: .UpdateLocation, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(showFullImage), name: NSNotification.Name(rawValue: "pushNotificationReceived"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func updateCurrentLocation() {
        clLocationManager.startUpdatingLocation()
    }
    
    @objc private func showFullImage(_ notification: Notification) {
        if let data = notification.userInfo {
            let payload = data["image"] as! String
            let data = JSON.init(parseJSON: payload)
            let image = Image(item: data.dictionaryObject!)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
            vc.image = image
            present(vc, animated: true)
        }
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
