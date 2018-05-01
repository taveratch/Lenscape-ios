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
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateCurrentLocation),
            name: .UpdateLocation,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showFullImage),
            name: NSNotification.Name(rawValue: "BackgroundNotificationReceived"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notificationReceived),
            name: NSNotification.Name(rawValue: "ForegroundNotificationReceived"),
            object: nil
        )
        
        if let notifications = ArchiveUtil.loadNotifications() {
            let unread = notifications.count
            customTabBar.items?[3].badgeValue = unread > 0 ? "\(unread)" : nil
            UIApplication.shared.applicationIconBadgeNumber = unread
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "BackgroundNotificationReceived"),
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name(rawValue: "ForegroundNotificationReceived"),
            object: nil
        )
    }
    
    @objc private func updateCurrentLocation() {
        clLocationManager.startUpdatingLocation()
    }
    
    @objc private func showFullImage(_ notification: Notification) {
        if let data = notification.userInfo {
            if let photoId = data["photo_id"] as? String {
                Api.retrievePhoto(photoId: Int(photoId)!).done { image in
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: Identifier.FullImageViewController.rawValue) as! FullImageViewController
                    vc.image = image
                    self.present(vc, animated: true)
                    }.catch { error in
                        let error = error as NSError
                        let message = error.userInfo["message"] as? String ?? "Error"
                        self.showAlertDialog(message: message)
                }
            }
        }
    }
    
    @objc private func notificationReceived(_ notification: Notification) {
        let notification = JSON(notification.userInfo!)
        let body = notification["aps"]["alert"]["body"].string
        let title = notification["aps"]["alert"]["subtitle"].string
        let photoId = notification["photo_id"].string
        let notificationItem = NotificationItem(title: title!, body: body!, photoId: photoId!)
        if var notifications = ArchiveUtil.loadNotifications() {
            notifications.append(notificationItem)
            ArchiveUtil.saveNotifications(notifications: notifications)
            let unread = notifications.count
            self.customTabBar.items?[3].badgeValue = "\(unread)"
            UIApplication.shared.applicationIconBadgeNumber = unread
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
